package com.llamamobile.androidjavasdkexample;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.widget.*;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.llamamobile.vd.VectorStore;
import com.llamamobile.vd.HNSWIndex;
import com.llamamobile.vd.DistanceMetric;
import com.llamamobile.vd.SearchResult;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class MainActivity extends AppCompatActivity {
    // Vector Store state
    private VectorStore vectorStore;
    private int vectorStoreCount = 0;
    private List<SearchResult> vectorStoreResults = new ArrayList<>();
    
    // HNSW Index state
    private HNSWIndex hnswIndex;
    private int hnswIndexCount = 0;
    private List<SearchResult> hnswIndexResults = new ArrayList<>();
    
    // Configuration state
    private int dimension = 128;
    private DistanceMetric selectedMetric = DistanceMetric.L2;
    private int hnswM = 16;
    private int hnswEfConstruction = 200;
    private int searchK = 5;
    private int efSearch = 50;
    
    // UI elements
    private TextView statusTextView;
    private SeekBar dimensionSeekBar;
    private TextView dimensionValue;
    private RadioGroup metricRadioGroup;
    private SeekBar hnswMSeekBar;
    private TextView hnswMValue;
    private SeekBar hnswEfConstructionSeekBar;
    private TextView hnswEfConstructionValue;
    private SeekBar searchKSeekBar;
    private TextView searchKValue;
    private SeekBar efSearchSeekBar;
    private TextView efSearchValue;
    
    private Button createVectorStoreButton;
    private Button addVectorsToStoreButton;
    private Button searchVectorStoreButton;
    private Button clearVectorStoreButton;
    private Button releaseVectorStoreButton;
    private TextView vectorStoreInfoTextView;
    private LinearLayout vectorStoreResultsContainer;
    private RecyclerView vectorStoreResultsRecyclerView;
    
    private Button createHNSWIndexButton;
    private Button addVectorsToHNSWButton;
    private Button searchHNSWIndexButton;
    private Button clearHNSWIndexButton;
    private Button releaseHNSWIndexButton;
    private TextView hnswIndexInfoTextView;
    private LinearLayout hnswIndexResultsContainer;
    private RecyclerView hnswIndexResultsRecyclerView;
    
    private final Handler handler = new Handler(Looper.getMainLooper());
    private final Random random = new Random();
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        initializeUI();
        setupEventListeners();
        updateVectorStoreInfo();
        updateHNSWIndexInfo();
    }
    
    private void initializeUI() {
        // Status
        statusTextView = findViewById(R.id.status_text_view);
        
        // Configuration
        dimensionSeekBar = findViewById(R.id.dimension_seek_bar);
        dimensionValue = findViewById(R.id.dimension_value);
        metricRadioGroup = findViewById(R.id.metric_radio_group);
        hnswMSeekBar = findViewById(R.id.hnsw_m_seek_bar);
        hnswMValue = findViewById(R.id.hnsw_m_value);
        hnswEfConstructionSeekBar = findViewById(R.id.hnsw_ef_construction_seek_bar);
        hnswEfConstructionValue = findViewById(R.id.hnsw_ef_construction_value);
        searchKSeekBar = findViewById(R.id.search_k_seek_bar);
        searchKValue = findViewById(R.id.search_k_value);
        efSearchSeekBar = findViewById(R.id.ef_search_seek_bar);
        efSearchValue = findViewById(R.id.ef_search_value);
        
        // VectorStore
        createVectorStoreButton = findViewById(R.id.create_vector_store_button);
        addVectorsToStoreButton = findViewById(R.id.add_vectors_to_store_button);
        searchVectorStoreButton = findViewById(R.id.search_vector_store_button);
        clearVectorStoreButton = findViewById(R.id.clear_vector_store_button);
        releaseVectorStoreButton = findViewById(R.id.release_vector_store_button);
        vectorStoreInfoTextView = findViewById(R.id.vector_store_info_text_view);
        vectorStoreResultsContainer = findViewById(R.id.vector_store_results_container);
        vectorStoreResultsRecyclerView = findViewById(R.id.vector_store_results_recycler_view);
        
        // HNSWIndex
        createHNSWIndexButton = findViewById(R.id.create_hnsw_index_button);
        addVectorsToHNSWButton = findViewById(R.id.add_vectors_to_hnsw_button);
        searchHNSWIndexButton = findViewById(R.id.search_hnsw_index_button);
        clearHNSWIndexButton = findViewById(R.id.clear_hnsw_index_button);
        releaseHNSWIndexButton = findViewById(R.id.release_hnsw_index_button);
        hnswIndexInfoTextView = findViewById(R.id.hnsw_index_info_text_view);
        hnswIndexResultsContainer = findViewById(R.id.hnsw_index_results_container);
        hnswIndexResultsRecyclerView = findViewById(R.id.hnsw_index_results_recycler_view);
        
        // Initialize values
        dimensionValue.setText(String.valueOf(dimension));
        metricRadioGroup.check(R.id.metric_l2);
        hnswMValue.setText(String.valueOf(hnswM));
        hnswEfConstructionValue.setText(String.valueOf(hnswEfConstruction));
        searchKValue.setText(String.valueOf(searchK));
        efSearchValue.setText(String.valueOf(efSearch));
        efSearchSeekBar.setMax(200);
        efSearchSeekBar.setProgress(efSearch);
        
        // Setup RecyclerViews
        vectorStoreResultsRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        vectorStoreResultsRecyclerView.setAdapter(new SearchResultsAdapter(new ArrayList<>()));
        
        hnswIndexResultsRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        hnswIndexResultsRecyclerView.setAdapter(new SearchResultsAdapter(new ArrayList<>()));
    }
    
    private void setupEventListeners() {
        // Configuration listeners
        dimensionSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                dimension = progress;
                dimensionValue.setText(String.valueOf(progress));
            }
            
            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}
            
            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {}
        });
        
        metricRadioGroup.setOnCheckedChangeListener((group, checkedId) -> {
            selectedMetric = switch (checkedId) {
                case R.id.metric_l2 -> DistanceMetric.L2;
                case R.id.metric_cosine -> DistanceMetric.COSINE;
                case R.id.metric_dot -> DistanceMetric.DOT;
                default -> DistanceMetric.L2;
            };
        });
        
        hnswMSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                hnswM = progress;
                hnswMValue.setText(String.valueOf(progress));
            }
            
            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}
            
            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {}
        });
        
        hnswEfConstructionSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                hnswEfConstruction = progress;
                hnswEfConstructionValue.setText(String.valueOf(progress));
            }
            
            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}
            
            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {}
        });
        
        searchKSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                searchK = progress;
                searchKValue.setText(String.valueOf(progress));
            }
            
            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}
            
            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {}
        });
        
        efSearchSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                efSearch = progress;
                efSearchValue.setText(String.valueOf(progress));
            }
            
            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}
            
            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {}
        });
        
        // VectorStore listeners
        createVectorStoreButton.setOnClickListener(v -> createVectorStore());
        
        addVectorsToStoreButton.setOnClickListener(v -> addVectorsToStore());
        
        searchVectorStoreButton.setOnClickListener(v -> searchVectorStore());
        
        clearVectorStoreButton.setOnClickListener(v -> clearVectorStore());
        
        releaseVectorStoreButton.setOnClickListener(v -> releaseVectorStore());
        
        // HNSWIndex listeners
        createHNSWIndexButton.setOnClickListener(v -> createHNSWIndex());
        
        addVectorsToHNSWButton.setOnClickListener(v -> addVectorsToHNSW());
        
        searchHNSWIndexButton.setOnClickListener(v -> searchHNSWIndex());
        
        clearHNSWIndexButton.setOnClickListener(v -> clearHNSWIndex());
        
        releaseHNSWIndexButton.setOnClickListener(v -> releaseHNSWIndex());
    }
    
    private void updateStatus(String message) {
        handler.post(() -> statusTextView.setText(message));
    }
    
    private float[] createRandomVector(int dimension) {
        float[] vector = new float[dimension];
        for (int i = 0; i < dimension; i++) {
            vector[i] = random.nextFloat() * 2 - 1;
        }
        return vector;
    }
    
    private void updateVectorStoreInfo() {
        String storeStatus = vectorStore != null ? getString(R.string.status_created) : getString(R.string.none);
        vectorStoreInfoTextView.setText(getString(R.string.label_vector_store_status) + ": " + storeStatus + "\n" + getString(R.string.label_vector_count) + ": " + vectorStoreCount);
    }
    
    private void updateHNSWIndexInfo() {
        String indexStatus = hnswIndex != null ? getString(R.string.status_created) : getString(R.string.none);
        hnswIndexInfoTextView.setText(getString(R.string.label_hnsw_index_status) + ": " + indexStatus + "\n" + getString(R.string.label_vector_count) + ": " + hnswIndexCount);
    }
    
    // VectorStore operations
    private void createVectorStore() {
        updateStatus(getString(R.string.status_creating_vector_store));
        
        new Thread(() -> {
            try {
                // First close any existing vector store
                if (vectorStore != null) {
                    vectorStore.close();
                }
                
                VectorStore newVectorStore = new VectorStore(dimension, selectedMetric);
                vectorStore = newVectorStore;
                vectorStoreCount = 0;
                vectorStoreResults.clear();
                
                handler.post(() -> {
                    vectorStoreResultsContainer.setVisibility(View.GONE);
                    updateVectorStoreInfo();
                    updateStatus(getString(R.string.status_vector_store_created));
                });
            } catch (Exception e) {
                handler.post(() -> {
                    updateStatus("Error creating VectorStore: " + e.getMessage());
                });
            }
        }).start();
    }
    
    private void addVectorsToStore() {
        if (vectorStore == null) {
            updateStatus(getString(R.string.status_please_create_vector_store_first));
            return;
        }
        
        updateStatus(getString(R.string.status_adding_vectors_to_store));
        
        new Thread(() -> {
            try {
                for (int i = 0; i < 100; i++) {
                    float[] vector = createRandomVector(dimension);
                    vectorStore.addVector(vector, i + 1);
                }
                
                int count = vectorStore.getCount();
                
                handler.post(() -> {
                    vectorStoreCount = count;
                    updateVectorStoreInfo();
                    updateStatus(getString(R.string.status_added_vectors_to_store));
                });
            } catch (Exception e) {
                handler.post(() -> {
                    updateStatus("Error adding vectors to VectorStore: " + e.getMessage());
                });
            }
        }).start();
    }
    
    private void searchVectorStore() {
        if (vectorStore == null) {
            updateStatus(getString(R.string.status_please_create_vector_store_first));
            return;
        }
        
        if (vectorStoreCount == 0) {
            updateStatus(getString(R.string.status_please_add_vectors_to_vector_store_first));
            return;
        }
        
        updateStatus(getString(R.string.status_searching_vector_store));
        
        new Thread(() -> {
            try {
                float[] queryVector = createRandomVector(dimension);
                SearchResult[] resultsArray = vectorStore.search(queryVector, searchK);
                List<SearchResult> results = new ArrayList<>();
                for (SearchResult result : resultsArray) {
                    results.add(result);
                }
                
                handler.post(() -> {
                    vectorStoreResults = results;
                    vectorStoreResultsRecyclerView.setAdapter(new SearchResultsAdapter(results));
                    vectorStoreResultsContainer.setVisibility(View.VISIBLE);
                    updateStatus(getString(R.string.status_search_completed));
                });
            } catch (Exception e) {
                handler.post(() -> {
                    updateStatus("Error searching VectorStore: " + e.getMessage());
                });
            }
        }).start();
    }
    
    private void clearVectorStore() {
        if (vectorStore == null) {
            updateStatus(getString(R.string.status_please_create_vector_store_first));
            return;
        }
        
        updateStatus(getString(R.string.status_clearing_vector_store));
        
        new Thread(() -> {
            try {
                vectorStore.clear();
                
                handler.post(() -> {
                    vectorStoreCount = 0;
                    vectorStoreResults.clear();
                    vectorStoreResultsContainer.setVisibility(View.GONE);
                    updateVectorStoreInfo();
                    updateStatus(getString(R.string.status_vector_store_cleared));
                });
            } catch (Exception e) {
                handler.post(() -> {
                    updateStatus("Error clearing VectorStore: " + e.getMessage());
                });
            }
        }).start();
    }
    
    private void releaseVectorStore() {
        if (vectorStore == null) {
            updateStatus(getString(R.string.status_please_create_vector_store_first));
            return;
        }
        
        updateStatus(getString(R.string.status_releasing_vector_store));
        
        new Thread(() -> {
            try {
                vectorStore.close();
                
                handler.post(() -> {
                    vectorStore = null;
                    vectorStoreCount = 0;
                    vectorStoreResults.clear();
                    vectorStoreResultsContainer.setVisibility(View.GONE);
                    updateVectorStoreInfo();
                    updateStatus(getString(R.string.status_vector_store_released));
                });
            } catch (Exception e) {
                handler.post(() -> {
                    updateStatus("Error releasing VectorStore: " + e.getMessage());
                });
            }
        }).start();
    }
    
    // HNSWIndex operations
    private void createHNSWIndex() {
        updateStatus(getString(R.string.status_creating_hnsw_index));
        
        new Thread(() -> {
            try {
                // First close any existing HNSW index
                if (hnswIndex != null) {
                    hnswIndex.close();
                }
                
                HNSWIndex newHnswIndex = new HNSWIndex(dimension, selectedMetric, hnswM, hnswEfConstruction);
                hnswIndex = newHnswIndex;
                hnswIndexCount = 0;
                hnswIndexResults.clear();
                
                handler.post(() -> {
                    hnswIndexResultsContainer.setVisibility(View.GONE);
                    updateHNSWIndexInfo();
                    updateStatus(getString(R.string.status_hnsw_index_created));
                });
            } catch (Exception e) {
                handler.post(() -> {
                    updateStatus("Error creating HNSWIndex: " + e.getMessage());
                });
            }
        }).start();
    }
    
    private void addVectorsToHNSW() {
        if (hnswIndex == null) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first));
            return;
        }
        
        updateStatus(getString(R.string.status_adding_vectors_to_hnsw));
        
        new Thread(() -> {
            try {
                for (int i = 0; i < 100; i++) {
                    float[] vector = createRandomVector(dimension);
                    hnswIndex.addVector(vector, i + 1);
                }
                
                int count = hnswIndex.getCount();
                
                handler.post(() -> {
                    hnswIndexCount = count;
                    updateHNSWIndexInfo();
                    updateStatus(getString(R.string.status_added_vectors_to_hnsw));
                });
            } catch (Exception e) {
                handler.post(() -> {
                    updateStatus("Error adding vectors to HNSWIndex: " + e.getMessage());
                });
            }
        }).start();
    }
    
    private void searchHNSWIndex() {
        if (hnswIndex == null) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first));
            return;
        }
        
        if (hnswIndexCount == 0) {
            updateStatus(getString(R.string.status_please_add_vectors_to_hnsw_index_first));
            return;
        }
        
        updateStatus(getString(R.string.status_searching_hnsw_index));
        
        new Thread(() -> {
            try {
                float[] queryVector = createRandomVector(dimension);
                SearchResult[] resultsArray = hnswIndex.search(queryVector, searchK, efSearch);
                List<SearchResult> results = new ArrayList<>();
                for (SearchResult result : resultsArray) {
                    results.add(result);
                }
                
                handler.post(() -> {
                    hnswIndexResults = results;
                    hnswIndexResultsRecyclerView.setAdapter(new SearchResultsAdapter(results));
                    hnswIndexResultsContainer.setVisibility(View.VISIBLE);
                    updateStatus(getString(R.string.status_search_completed));
                });
            } catch (Exception e) {
                handler.post(() -> {
                    updateStatus("Error searching HNSWIndex: " + e.getMessage());
                });
            }
        }).start();
    }
    
    private void clearHNSWIndex() {
        if (hnswIndex == null) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first));
            return;
        }
        
        updateStatus(getString(R.string.status_clearing_hnsw_index));
        
        new Thread(() -> {
            try {
                hnswIndex.clear();
                
                handler.post(() -> {
                    hnswIndexCount = 0;
                    hnswIndexResults.clear();
                    hnswIndexResultsContainer.setVisibility(View.GONE);
                    updateHNSWIndexInfo();
                    updateStatus(getString(R.string.status_hnsw_index_cleared));
                });
            } catch (Exception e) {
                handler.post(() -> {
                    updateStatus("Error clearing HNSWIndex: " + e.getMessage());
                });
            }
        }).start();
    }
    
    private void releaseHNSWIndex() {
        if (hnswIndex == null) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first));
            return;
        }
        
        updateStatus(getString(R.string.status_releasing_hnsw_index));
        
        new Thread(() -> {
            try {
                hnswIndex.close();
                
                handler.post(() -> {
                    hnswIndex = null;
                    hnswIndexCount = 0;
                    hnswIndexResults.clear();
                    hnswIndexResultsContainer.setVisibility(View.GONE);
                    updateHNSWIndexInfo();
                    updateStatus(getString(R.string.status_hnsw_index_released));
                });
            } catch (Exception e) {
                handler.post(() -> {
                    updateStatus("Error releasing HNSWIndex: " + e.getMessage());
                });
            }
        }).start();
    }
    
    // Search Results Adapter
    private class SearchResultsAdapter extends RecyclerView.Adapter<SearchResultsAdapter.ViewHolder> {
        private final List<SearchResult> results;
        
        public SearchResultsAdapter(List<SearchResult> results) {
            this.results = results;
        }
        
        public class ViewHolder extends RecyclerView.ViewHolder {
            public TextView vectorIndexTextView;
            public TextView distanceTextView;
            
            public ViewHolder(View itemView) {
                super(itemView);
                vectorIndexTextView = itemView.findViewById(android.R.id.text1);
                distanceTextView = itemView.findViewById(android.R.id.text2);
            }
        }
        
        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            View itemView = getLayoutInflater().inflate(android.R.layout.simple_list_item_2, parent, false);
            return new ViewHolder(itemView);
        }
        
        @Override
        public void onBindViewHolder(ViewHolder holder, int position) {
            SearchResult result = results.get(position);
            holder.vectorIndexTextView.setText("Vector ID: " + result.getId());
            holder.distanceTextView.setText("Distance: " + String.format("%.6f", result.getDistance()));
            holder.distanceTextView.setTextColor(getResources().getColor(android.R.color.darker_gray));
        }
        
        @Override
        public int getItemCount() {
            return results.size();
        }
    }
}
