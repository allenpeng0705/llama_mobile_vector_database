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
import com.llamamobile.vd.MMapVectorStore;
import com.llamamobile.vd.MMapVectorStoreBuilder;
import com.llamamobile.vd.LlamaMobileVD;
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
    
    // MMapVectorStore state
    private MMapVectorStore mmapVectorStore;
    private int mmapVectorStoreCount = 0;
    private List<SearchResult> mmapVectorStoreResults = new ArrayList<>();
    
    // MMapVectorStoreBuilder state
    private MMapVectorStoreBuilder mmapVectorStoreBuilder;
    private int mmapVectorStoreBuilderCount = 0;
    
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
    private Button getVectorFromStoreButton;
    private Button updateVectorInStoreButton;
    private Button removeVectorFromStoreButton;
    private Button containsVectorInStoreButton;
    private Button reserveVectorStoreButton;
    private Button getVectorStoreDimensionButton;
    private Button getVectorStoreMetricButton;
    private TextView vectorStoreInfoTextView;
    private LinearLayout vectorStoreResultsContainer;
    private RecyclerView vectorStoreResultsRecyclerView;
    
    private Button createHNSWIndexButton;
    private Button addVectorsToHNSWButton;
    private Button searchHNSWIndexButton;
    private Button clearHNSWIndexButton;
    private Button releaseHNSWIndexButton;
    private Button setHNSWEfSearchButton;
    private Button getHNSWEfSearchButton;
    private Button containsVectorInHNSWButton;
    private Button getVectorFromHNSWButton;
    private Button getHNSWDimensionButton;
    private Button getHNSWCapacityButton;
    private TextView hnswIndexInfoTextView;
    private LinearLayout hnswIndexResultsContainer;
    private RecyclerView hnswIndexResultsRecyclerView;
    
    // MMapVectorStore UI elements
    private EditText mmapFilePathEditText;
    private Button openMMapVectorStoreButton;
    private Button searchMMapVectorStoreButton;
    private Button getMMapVectorStoreCountButton;
    private Button getMMapVectorStoreDimensionButton;
    private Button getMMapVectorStoreMetricButton;
    private Button releaseMMapVectorStoreButton;
    private TextView mmapVectorStoreInfoTextView;
    private LinearLayout mmapVectorStoreResultsContainer;
    private RecyclerView mmapVectorStoreResultsRecyclerView;
    
    // MMapVectorStoreBuilder UI elements
    private Button createMMapVectorStoreBuilderButton;
    private Button addVectorsToBuilderButton;
    private Button saveMMapVectorStoreButton;
    private Button clearMMapVectorStoreBuilderButton;
    private Button releaseMMapVectorStoreBuilderButton;
    
    private Handler handler = new Handler(Looper.getMainLooper());
    private Random random = new Random();
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        initializeUI();
        setupEventListeners();
        updateVectorStoreInfo();
        updateHNSWIndexInfo();
        updateMMapVectorStoreInfo();
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
        getVectorFromStoreButton = findViewById(R.id.get_vector_from_store_button);
        updateVectorInStoreButton = findViewById(R.id.update_vector_in_store_button);
        removeVectorFromStoreButton = findViewById(R.id.remove_vector_from_store_button);
        containsVectorInStoreButton = findViewById(R.id.contains_vector_in_store_button);
        reserveVectorStoreButton = findViewById(R.id.reserve_vector_store_button);
        getVectorStoreDimensionButton = findViewById(R.id.get_vector_store_dimension_button);
        getVectorStoreMetricButton = findViewById(R.id.get_vector_store_metric_button);
        vectorStoreInfoTextView = findViewById(R.id.vector_store_info_text_view);
        vectorStoreResultsContainer = findViewById(R.id.vector_store_results_container);
        vectorStoreResultsRecyclerView = findViewById(R.id.vector_store_results_recycler_view);
        
        // HNSWIndex
        createHNSWIndexButton = findViewById(R.id.create_hnsw_index_button);
        addVectorsToHNSWButton = findViewById(R.id.add_vectors_to_hnsw_button);
        searchHNSWIndexButton = findViewById(R.id.search_hnsw_index_button);
        clearHNSWIndexButton = findViewById(R.id.clear_hnsw_index_button);
        releaseHNSWIndexButton = findViewById(R.id.release_hnsw_index_button);
        setHNSWEfSearchButton = findViewById(R.id.set_hnsw_ef_search_button);
        getHNSWEfSearchButton = findViewById(R.id.get_hnsw_ef_search_button);
        containsVectorInHNSWButton = findViewById(R.id.contains_vector_in_hnsw_button);
        getVectorFromHNSWButton = findViewById(R.id.get_vector_from_hnsw_button);
        getHNSWDimensionButton = findViewById(R.id.get_hnsw_dimension_button);
        getHNSWCapacityButton = findViewById(R.id.get_hnsw_capacity_button);
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
        
        // Initialize efSearch seekbar
        efSearchSeekBar.setMax(200);
        efSearchSeekBar.setProgress(efSearch);
        
        // Setup RecyclerViews
        vectorStoreResultsRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        vectorStoreResultsRecyclerView.setAdapter(new SearchResultsAdapter(new ArrayList<>()));
        
        hnswIndexResultsRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        hnswIndexResultsRecyclerView.setAdapter(new SearchResultsAdapter(new ArrayList<>()));
        
        // MMapVectorStore UI elements
        mmapFilePathEditText = findViewById(R.id.mmap_file_path_edit_text);
        openMMapVectorStoreButton = findViewById(R.id.open_mmap_vector_store_button);
        searchMMapVectorStoreButton = findViewById(R.id.search_mmap_vector_store_button);
        getMMapVectorStoreCountButton = findViewById(R.id.get_mmap_vector_store_count_button);
        getMMapVectorStoreDimensionButton = findViewById(R.id.get_mmap_vector_store_dimension_button);
        getMMapVectorStoreMetricButton = findViewById(R.id.get_mmap_vector_store_metric_button);
        releaseMMapVectorStoreButton = findViewById(R.id.release_mmap_vector_store_button);
        mmapVectorStoreInfoTextView = findViewById(R.id.mmap_vector_store_info_text_view);
        mmapVectorStoreResultsContainer = findViewById(R.id.mmap_vector_store_results_container);
        mmapVectorStoreResultsRecyclerView = findViewById(R.id.mmap_vector_store_results_recycler_view);
        
        // Setup MMapVectorStore RecyclerView
        mmapVectorStoreResultsRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        mmapVectorStoreResultsRecyclerView.setAdapter(new SearchResultsAdapter(new ArrayList<>()));
        
        // MMapVectorStoreBuilder UI elements initialization
        createMMapVectorStoreBuilderButton = findViewById(R.id.create_mmap_vector_store_builder_button);
        addVectorsToBuilderButton = findViewById(R.id.add_vectors_to_builder_button);
        saveMMapVectorStoreButton = findViewById(R.id.save_mmap_vector_store_button);
        clearMMapVectorStoreBuilderButton = findViewById(R.id.clear_mmap_vector_store_builder_button);
        releaseMMapVectorStoreBuilderButton = findViewById(R.id.release_mmap_vector_store_builder_button);
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
        
        metricRadioGroup.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                switch (checkedId) {
                    case R.id.metric_l2:
                        selectedMetric = DistanceMetric.L2;
                        break;
                    case R.id.metric_cosine:
                        selectedMetric = DistanceMetric.COSINE;
                        break;
                    case R.id.metric_dot:
                        selectedMetric = DistanceMetric.DOT;
                        break;
                    default:
                        selectedMetric = DistanceMetric.L2;
                }
            }
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
        
        // efSearch seekbar listener
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
        createVectorStoreButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                createVectorStore();
            }
        });
        
        addVectorsToStoreButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                addVectorsToStore();
            }
        });
        
        searchVectorStoreButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                searchVectorStore();
            }
        });
        
        clearVectorStoreButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                clearVectorStore();
            }
        });
        
        releaseVectorStoreButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                releaseVectorStore();
            }
        });
        
        getVectorFromStoreButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                getVectorFromStore();
            }
        });
        
        updateVectorInStoreButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                updateVectorInStore();
            }
        });
        
        removeVectorFromStoreButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                removeVectorFromStore();
            }
        });
        
        containsVectorInStoreButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                containsVectorInStore();
            }
        });
        
        reserveVectorStoreButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                reserveVectorStore();
            }
        });
        
        getVectorStoreDimensionButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                getVectorStoreDimension();
            }
        });
        
        getVectorStoreMetricButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                getVectorStoreMetric();
            }
        });
        
        // HNSWIndex listeners
        createHNSWIndexButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                createHNSWIndex();
            }
        });
        
        addVectorsToHNSWButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                addVectorsToHNSW();
            }
        });
        
        searchHNSWIndexButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                searchHNSWIndex();
            }
        });
        
        clearHNSWIndexButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                clearHNSWIndex();
            }
        });
        
        releaseHNSWIndexButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                releaseHNSWIndex();
            }
        });
        
        setHNSWEfSearchButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                setHNSWEfSearch();
            }
        });
        
        getHNSWEfSearchButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                getHNSWEfSearch();
            }
        });
        
        containsVectorInHNSWButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                containsVectorInHNSW();
            }
        });
        
        getVectorFromHNSWButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                getVectorFromHNSW();
            }
        });
        
        getHNSWDimensionButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                getHNSWDimension();
            }
        });
        
        getHNSWCapacityButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                getHNSWCapacity();
            }
        });
        
        // MMapVectorStore listeners
        openMMapVectorStoreButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                openMMapVectorStore();
            }
        });
        
        searchMMapVectorStoreButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                searchMMapVectorStore();
            }
        });
        
        getMMapVectorStoreCountButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                getMMapVectorStoreCount();
            }
        });
        
        getMMapVectorStoreDimensionButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                getMMapVectorStoreDimension();
            }
        });
        
        getMMapVectorStoreMetricButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                getMMapVectorStoreMetric();
            }
        });
        
        releaseMMapVectorStoreButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                releaseMMapVectorStore();
            }
        });
        
        // MMapVectorStoreBuilder listeners
        createMMapVectorStoreBuilderButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                createMMapVectorStoreBuilder();
            }
        });
        
        addVectorsToBuilderButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                addVectorsToBuilder();
            }
        });
        
        saveMMapVectorStoreButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                saveMMapVectorStore();
            }
        });
        
        clearMMapVectorStoreBuilderButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                clearMMapVectorStoreBuilder();
            }
        });
        
        releaseMMapVectorStoreBuilderButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                releaseMMapVectorStoreBuilder();
            }
        });
    }
    
    private void updateStatus(String message) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                statusTextView.setText(message);
            }
        });
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
    
    private void updateMMapVectorStoreInfo() {
        String storeStatus = mmapVectorStore != null ? getString(R.string.status_created) : getString(R.string.none);
        mmapVectorStoreInfoTextView.setText(getString(R.string.label_mmap_vector_store_status) + ": " + storeStatus + "\n" + getString(R.string.label_vector_count) + ": " + mmapVectorStoreCount);
    }
    
    // VectorStore operations
    private void createVectorStore() {
        updateStatus(getString(R.string.status_creating_vector_store));
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    // First close any existing vector store
                    if (vectorStore != null) {
                        vectorStore.close();
                    }
                    
                    VectorStore newVectorStore = new VectorStore(dimension, selectedMetric);
                    vectorStore = newVectorStore;
                    vectorStoreCount = 0;
                    vectorStoreResults.clear();
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            vectorStoreResultsContainer.setVisibility(LinearLayout.GONE);
                            updateVectorStoreInfo();
                            updateStatus(getString(R.string.status_vector_store_created));
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error creating VectorStore: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void addVectorsToStore() {
        if (vectorStore == null) {
            updateStatus(getString(R.string.status_please_create_vector_store_first));
            return;
        }
        
        updateStatus(getString(R.string.status_adding_vectors_to_store));
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    for (int i = 0; i < 100; i++) {
                        float[] vector = createRandomVector(dimension);
                        vectorStore.add((long) (i + 1), vector);
                    }
                    
                    int count = vectorStore.size();
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            vectorStoreCount = count;
                            updateVectorStoreInfo();
                            updateStatus(getString(R.string.status_added_vectors_to_store));
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error adding vectors to VectorStore: " + e.getMessage());
                        }
                    });
                }
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
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    float[] queryVector = createRandomVector(dimension);
                    SearchResult[] results = vectorStore.search(queryVector, searchK);
                    
                    List<SearchResult> resultList = new ArrayList<>();
                    for (SearchResult result : results) {
                        resultList.add(result);
                    }
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            vectorStoreResults = resultList;
                            vectorStoreResultsRecyclerView.setAdapter(new SearchResultsAdapter(resultList));
                            vectorStoreResultsContainer.setVisibility(LinearLayout.VISIBLE);
                            updateStatus(getString(R.string.status_search_completed));
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error searching VectorStore: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void clearVectorStore() {
        if (vectorStore == null) {
            updateStatus(getString(R.string.status_please_create_vector_store_first));
            return;
        }
        
        updateStatus(getString(R.string.status_clearing_vector_store));
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    vectorStore.clear();
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            vectorStoreCount = 0;
                            vectorStoreResults.clear();
                            vectorStoreResultsContainer.setVisibility(LinearLayout.GONE);
                            updateVectorStoreInfo();
                            updateStatus(getString(R.string.status_vector_store_cleared));
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error clearing VectorStore: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void releaseVectorStore() {
        if (vectorStore == null) {
            updateStatus(getString(R.string.status_please_create_vector_store_first));
            return;
        }
        
        updateStatus(getString(R.string.status_releasing_vector_store));
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    vectorStore.close();
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            vectorStore = null;
                            vectorStoreCount = 0;
                            vectorStoreResults.clear();
                            vectorStoreResultsContainer.setVisibility(LinearLayout.GONE);
                            updateVectorStoreInfo();
                            updateStatus(getString(R.string.status_vector_store_released));
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error releasing VectorStore: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void getVectorFromStore() {
        if (vectorStore == null) {
            updateStatus(getString(R.string.status_please_create_vector_store_first));
            return;
        }
        
        updateStatus("Getting vector from VectorStore...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    long vectorId = 1; // Get the first vector
                    float[] vector = vectorStore.get(vectorId);
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Successfully retrieved vector with ID " + vectorId + ", first value: " + (vector != null ? vector[0] : "null"));
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error getting vector from VectorStore: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void updateVectorInStore() {
        if (vectorStore == null) {
            updateStatus(getString(R.string.status_please_create_vector_store_first));
            return;
        }
        
        updateStatus("Updating vector in VectorStore...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    long vectorId = 1; // Update the first vector
                    float[] updatedVector = createRandomVector(dimension);
                    boolean success = vectorStore.update(vectorId, updatedVector);
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus(success ? "Successfully updated vector with ID " + vectorId : "Failed to update vector");
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error updating vector in VectorStore: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void removeVectorFromStore() {
        if (vectorStore == null) {
            updateStatus(getString(R.string.status_please_create_vector_store_first));
            return;
        }
        
        updateStatus("Removing vector from VectorStore...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    long vectorId = 1; // Remove the first vector
                    boolean success = vectorStore.remove(vectorId);
                    int count = vectorStore.size();
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            vectorStoreCount = count;
                            updateVectorStoreInfo();
                            updateStatus(success ? "Successfully removed vector with ID " + vectorId : "Failed to remove vector");
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error removing vector from VectorStore: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void containsVectorInStore() {
        if (vectorStore == null) {
            updateStatus(getString(R.string.status_please_create_vector_store_first));
            return;
        }
        
        updateStatus("Checking if vector exists in VectorStore...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    long vectorId = 1;
                    boolean contains = vectorStore.contains(vectorId);
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Vector with ID " + vectorId + " " + (contains ? "exists" : "does not exist") + " in VectorStore");
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error checking vector existence: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void reserveVectorStore() {
        if (vectorStore == null) {
            updateStatus(getString(R.string.status_please_create_vector_store_first));
            return;
        }
        
        updateStatus("Reserving space in VectorStore...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    int reserveSize = 200;
                    vectorStore.reserve(reserveSize);
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Successfully reserved space for " + reserveSize + " vectors in VectorStore");
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error reserving space in VectorStore: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void getVectorStoreDimension() {
        if (vectorStore == null) {
            updateStatus(getString(R.string.status_please_create_vector_store_first));
            return;
        }
        
        updateStatus("Getting VectorStore dimension...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    int storeDimension = vectorStore.dimension();
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("VectorStore dimension: " + storeDimension);
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error getting VectorStore dimension: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void getVectorStoreMetric() {
        if (vectorStore == null) {
            updateStatus(getString(R.string.status_please_create_vector_store_first));
            return;
        }
        
        updateStatus("Getting VectorStore distance metric...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    DistanceMetric metric = vectorStore.metric();
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("VectorStore distance metric: " + metric);
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error getting VectorStore metric: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    // HNSWIndex operations
    private void createHNSWIndex() {
        updateStatus(getString(R.string.status_creating_hnsw_index));
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    // First close any existing HNSW index
                    if (hnswIndex != null) {
                        hnswIndex.close();
                    }
                    
                    int maxElements = 10000; // Adjust based on needs
                    HNSWIndex newHnswIndex = new HNSWIndex(dimension, selectedMetric, maxElements, hnswM, hnswEfConstruction);
                    hnswIndex = newHnswIndex;
                    hnswIndexCount = 0;
                    hnswIndexResults.clear();
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            hnswIndexResultsContainer.setVisibility(LinearLayout.GONE);
                            updateHNSWIndexInfo();
                            updateStatus(getString(R.string.status_hnsw_index_created));
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error creating HNSWIndex: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void addVectorsToHNSW() {
        if (hnswIndex == null) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first));
            return;
        }
        
        updateStatus(getString(R.string.status_adding_vectors_to_hnsw));
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    for (int i = 0; i < 100; i++) {
                        float[] vector = createRandomVector(dimension);
                        hnswIndex.add((long) (i + 1), vector);
                    }
                    
                    int count = hnswIndex.size();
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            hnswIndexCount = count;
                            updateHNSWIndexInfo();
                            updateStatus(getString(R.string.status_added_vectors_to_hnsw));
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error adding vectors to HNSWIndex: " + e.getMessage());
                        }
                    });
                }
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
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    float[] queryVector = createRandomVector(dimension);
                    // Set efSearch parameter first
                    hnswIndex.setEfSearch(efSearch);
                    SearchResult[] results = hnswIndex.search(queryVector, searchK);
                    
                    List<SearchResult> resultList = new ArrayList<>();
                    for (SearchResult result : results) {
                        resultList.add(result);
                    }
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            hnswIndexResults = resultList;
                            hnswIndexResultsRecyclerView.setAdapter(new SearchResultsAdapter(resultList));
                            hnswIndexResultsContainer.setVisibility(LinearLayout.VISIBLE);
                            updateStatus(getString(R.string.status_search_completed));
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error searching HNSWIndex: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void clearHNSWIndex() {
        if (hnswIndex == null) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first));
            return;
        }
        
        updateStatus(getString(R.string.status_clearing_hnsw_index));
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    hnswIndex.clear();
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            hnswIndexCount = 0;
                            hnswIndexResults.clear();
                            hnswIndexResultsContainer.setVisibility(LinearLayout.GONE);
                            updateHNSWIndexInfo();
                            updateStatus(getString(R.string.status_hnsw_index_cleared));
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error clearing HNSWIndex: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void releaseHNSWIndex() {
        if (hnswIndex == null) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first));
            return;
        }
        
        updateStatus(getString(R.string.status_releasing_hnsw_index));
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    hnswIndex.close();
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            hnswIndex = null;
                            hnswIndexCount = 0;
                            hnswIndexResults.clear();
                            hnswIndexResultsContainer.setVisibility(LinearLayout.GONE);
                            updateHNSWIndexInfo();
                            updateStatus(getString(R.string.status_hnsw_index_released));
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error releasing HNSWIndex: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void setHNSWEfSearch() {
        if (hnswIndex == null) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first));
            return;
        }
        
        updateStatus("Setting HNSW efSearch...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    hnswIndex.setEfSearch(efSearch);
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Successfully set HNSW efSearch to " + efSearch);
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error setting HNSW efSearch: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void getHNSWEfSearch() {
        if (hnswIndex == null) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first));
            return;
        }
        
        updateStatus("Getting HNSW efSearch...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    int currentEfSearch = hnswIndex.getEfSearch();
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("HNSW efSearch: " + currentEfSearch);
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error getting HNSW efSearch: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void containsVectorInHNSW() {
        if (hnswIndex == null) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first));
            return;
        }
        
        updateStatus("Checking if vector exists in HNSW...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    long vectorId = 1;
                    boolean contains = hnswIndex.contains(vectorId);
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Vector with ID " + vectorId + " " + (contains ? "exists" : "does not exist") + " in HNSW");
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error checking vector existence in HNSW: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void getVectorFromHNSW() {
        if (hnswIndex == null) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first));
            return;
        }
        
        updateStatus("Getting vector from HNSW...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    long vectorId = 1;
                    float[] vector = hnswIndex.get(vectorId);
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Successfully retrieved vector with ID " + vectorId + " from HNSW, first value: " + (vector != null ? vector[0] : "null"));
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error getting vector from HNSW: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void getHNSWDimension() {
        if (hnswIndex == null) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first));
            return;
        }
        
        updateStatus("Getting HNSW dimension...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    int dimension = hnswIndex.dimension();
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("HNSW dimension: " + dimension);
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error getting HNSW dimension: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void getHNSWCapacity() {
        if (hnswIndex == null) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first));
            return;
        }
        
        updateStatus("Getting HNSW capacity...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    int capacity = hnswIndex.capacity();
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("HNSW capacity: " + capacity);
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error getting HNSW capacity: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    // MMapVectorStore operations
    private void openMMapVectorStore() {
        String filePath = mmapFilePathEditText.getText().toString().trim();
        if (filePath.isEmpty()) {
            updateStatus("Please enter a valid file path");
            return;
        }
        
        updateStatus(getString(R.string.status_opening_mmap_vector_store));
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    // First close any existing MMapVectorStore
                    if (mmapVectorStore != null) {
                        mmapVectorStore.close();
                    }
                    
                    MMapVectorStore newMMapVectorStore = MMapVectorStore.open(filePath);
                    mmapVectorStore = newMMapVectorStore;
                    int count = newMMapVectorStore.size();
                    mmapVectorStoreCount = count;
                    mmapVectorStoreResults.clear();
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            mmapVectorStoreResultsContainer.setVisibility(LinearLayout.GONE);
                            updateMMapVectorStoreInfo();
                            updateStatus(getString(R.string.status_mmap_vector_store_opened));
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error opening MMapVectorStore: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void searchMMapVectorStore() {
        if (mmapVectorStore == null) {
            updateStatus(getString(R.string.status_please_open_mmap_vector_store_first));
            return;
        }
        
        if (mmapVectorStoreCount == 0) {
            updateStatus("MMapVectorStore is empty");
            return;
        }
        
        updateStatus(getString(R.string.status_searching_mmap_vector_store));
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    // Get the dimension from the store
                    int storeDimension = mmapVectorStore.dimension();
                    float[] queryVector = createRandomVector(storeDimension);
                    SearchResult[] results = mmapVectorStore.search(queryVector, searchK);
                    
                    List<SearchResult> resultList = new ArrayList<>();
                    for (SearchResult result : results) {
                        resultList.add(result);
                    }
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            mmapVectorStoreResults = resultList;
                            mmapVectorStoreResultsRecyclerView.setAdapter(new SearchResultsAdapter(resultList));
                            mmapVectorStoreResultsContainer.setVisibility(LinearLayout.VISIBLE);
                            updateStatus(getString(R.string.status_search_completed));
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error searching MMapVectorStore: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void getMMapVectorStoreCount() {
        if (mmapVectorStore == null) {
            updateStatus(getString(R.string.status_please_open_mmap_vector_store_first));
            return;
        }
        
        updateStatus("Getting MMapVectorStore count...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    int count = mmapVectorStore.size();
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            mmapVectorStoreCount = count;
                            updateMMapVectorStoreInfo();
                            updateStatus("MMapVectorStore count: " + count);
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error getting MMapVectorStore count: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void getMMapVectorStoreDimension() {
        if (mmapVectorStore == null) {
            updateStatus(getString(R.string.status_please_open_mmap_vector_store_first));
            return;
        }
        
        updateStatus("Getting MMapVectorStore dimension...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    int dimension = mmapVectorStore.dimension();
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("MMapVectorStore dimension: " + dimension);
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error getting MMapVectorStore dimension: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void getMMapVectorStoreMetric() {
        if (mmapVectorStore == null) {
            updateStatus(getString(R.string.status_please_open_mmap_vector_store_first));
            return;
        }
        
        updateStatus("Getting MMapVectorStore metric...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    DistanceMetric metric = mmapVectorStore.metric();
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("MMapVectorStore metric: " + metric);
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error getting MMapVectorStore metric: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void releaseMMapVectorStore() {
        if (mmapVectorStore == null) {
            updateStatus(getString(R.string.status_please_open_mmap_vector_store_first));
            return;
        }
        
        updateStatus(getString(R.string.status_releasing_mmap_vector_store));
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    mmapVectorStore.close();
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            mmapVectorStore = null;
                            mmapVectorStoreCount = 0;
                            mmapVectorStoreResults.clear();
                            mmapVectorStoreResultsContainer.setVisibility(LinearLayout.GONE);
                            updateMMapVectorStoreInfo();
                            updateStatus(getString(R.string.status_mmap_vector_store_released));
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error releasing MMapVectorStore: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    // MMapVectorStoreBuilder operations
    private void createMMapVectorStoreBuilder() {
        updateStatus("Creating MMapVectorStoreBuilder...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    // First close any existing builder
                    if (mmapVectorStoreBuilder != null) {
                        mmapVectorStoreBuilder.close();
                    }
                    
                    mmapVectorStoreBuilder = new MMapVectorStoreBuilder(dimension, selectedMetric);
                    mmapVectorStoreBuilderCount = 0;
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("MMapVectorStoreBuilder created successfully");
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error creating MMapVectorStoreBuilder: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void addVectorsToBuilder() {
        if (mmapVectorStoreBuilder == null) {
            updateStatus("Please create MMapVectorStoreBuilder first");
            return;
        }
        
        updateStatus("Adding vectors to MMapVectorStoreBuilder...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    for (int i = 0; i < 100; i++) {
                        float[] vector = createRandomVector(dimension);
                        mmapVectorStoreBuilder.add((mmapVectorStoreBuilderCount + i + 1), vector);
                    }
                    
                    int count = mmapVectorStoreBuilder.size();
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            mmapVectorStoreBuilderCount = count;
                            updateStatus("Added 100 vectors to MMapVectorStoreBuilder. Total: " + count);
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error adding vectors to MMapVectorStoreBuilder: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void saveMMapVectorStore() {
        String filePath = mmapFilePathEditText.getText().toString().trim();
        if (filePath.isEmpty()) {
            updateStatus("Please enter a valid file path");
            return;
        }
        
        if (mmapVectorStoreBuilder == null) {
            updateStatus("Please create MMapVectorStoreBuilder first");
            return;
        }
        
        updateStatus("Saving MMapVectorStore to file...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    mmapVectorStoreBuilder.save(filePath);
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("MMapVectorStore saved successfully to " + filePath);
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error saving MMapVectorStore: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void clearMMapVectorStoreBuilder() {
        if (mmapVectorStoreBuilder == null) {
            updateStatus("Please create MMapVectorStoreBuilder first");
            return;
        }
        
        updateStatus("Clearing MMapVectorStoreBuilder...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    mmapVectorStoreBuilder.close();
                    mmapVectorStoreBuilder = new MMapVectorStoreBuilder(dimension, selectedMetric);
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            mmapVectorStoreBuilderCount = 0;
                            updateStatus("MMapVectorStoreBuilder cleared successfully");
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error clearing MMapVectorStoreBuilder: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    private void releaseMMapVectorStoreBuilder() {
        if (mmapVectorStoreBuilder == null) {
            updateStatus("Please create MMapVectorStoreBuilder first");
            return;
        }
        
        updateStatus("Releasing MMapVectorStoreBuilder...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    mmapVectorStoreBuilder.close();
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            mmapVectorStoreBuilder = null;
                            mmapVectorStoreBuilderCount = 0;
                            updateStatus("MMapVectorStoreBuilder released successfully");
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error releasing MMapVectorStoreBuilder: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
    // SearchResultsAdapter class for RecyclerView
    class SearchResultsAdapter extends RecyclerView.Adapter<SearchResultsAdapter.SearchResultViewHolder> {
        private List<SearchResult> searchResults;
        
        SearchResultsAdapter(List<SearchResult> searchResults) {
            this.searchResults = searchResults;
        }
        
        @Override
        public SearchResultViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            View itemView = getLayoutInflater().inflate(android.R.layout.simple_list_item_1, parent, false);
            return new SearchResultViewHolder(itemView);
        }
        
        @Override
        public void onBindViewHolder(SearchResultViewHolder holder, int position) {
            SearchResult result = searchResults.get(position);
            holder.textView.setText("ID: " + result.id + ", Distance: " + String.format("%.6f", result.distance));
        }
        
        @Override
        public int getItemCount() {
            return searchResults.size();
        }
        
        class SearchResultViewHolder extends RecyclerView.ViewHolder {
            TextView textView;
            
            SearchResultViewHolder(View view) {
                super(view);
                textView = view.findViewById(android.R.id.text1);
            }
        }
    }
}
