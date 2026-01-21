package com.llamamobile.androidjavasdkexample;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.view.ViewGroup;
import android.widget.*;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.llamamobile.vd.LlamaMobileVD;
import com.llamamobile.vd.LlamaMobileVD.SearchResult;
import com.llamamobile.vd.LlamaMobileVD.DistanceMetric;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class MainActivity extends AppCompatActivity {
    // Vector Store state
    private long vectorStoreHandle = 0;
    private int vectorStoreCount = 0;
    private List<SearchResult> vectorStoreResults = new ArrayList<>();
    
    // HNSW Index state
    private long hnswIndexHandle = 0;
    private int hnswIndexCount = 0;
    private List<SearchResult> hnswIndexResults = new ArrayList<>();
    
    // MMapVectorStore state
    private long mmapVectorStoreHandle = 0;
    private int mmapVectorStoreCount = 0;
    private List<SearchResult> mmapVectorStoreResults = new ArrayList<>();
    

    
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
    
    // MMapVectorStore UI elements
    private EditText mmapFilePathEditText;
    private Button createMMapVectorStoreButton;
    private Button openMMapVectorStoreButton;
    private Button searchMMapVectorStoreButton;
    private Button releaseMMapVectorStoreButton;
    private TextView mmapVectorStoreInfoTextView;
    private LinearLayout mmapVectorStoreResultsContainer;
    private RecyclerView mmapVectorStoreResultsRecyclerView;
    

    
    private Handler handler = new Handler(Looper.getMainLooper());
    private Random random = new Random();
    
    private static final int STORAGE_PERMISSION_CODE = 101;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        requestStoragePermission();
        initializeUI();
        setupEventListeners();
        updateVectorStoreInfo();
        updateHNSWIndexInfo();
        updateMMapVectorStoreInfo();
    }

    private void requestStoragePermission() {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
            if (checkSelfPermission(android.Manifest.permission.WRITE_EXTERNAL_STORAGE) != android.content.pm.PackageManager.PERMISSION_GRANTED) {
                requestPermissions(new String[]{android.Manifest.permission.WRITE_EXTERNAL_STORAGE, android.Manifest.permission.READ_EXTERNAL_STORAGE}, STORAGE_PERMISSION_CODE);
            }
        }
        
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
            if (!android.os.Environment.isExternalStorageManager()) {
                Intent intent = new Intent(android.provider.Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION);
                startActivity(intent);
            }
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == STORAGE_PERMISSION_CODE) {
            if (grantResults.length > 0 && grantResults[0] == android.content.pm.PackageManager.PERMISSION_GRANTED) {
                updateStatus("Storage permission granted");
            } else {
                updateStatus("Storage permission denied. MMapVectorStore operations may fail.");
            }
        }
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
        // efSearchSeekBar and efSearchValue are not present in the XML layout
        // Using default value of 50 for efSearch
        
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
        // Missing buttons:
        // setHNSWEfSearchButton
        // getHNSWEfSearchButton
        // containsVectorInHNSWButton
        // getVectorFromHNSWButton
        // getHNSWDimensionButton
        // getHNSWCapacityButton
        hnswIndexInfoTextView = findViewById(R.id.hnsw_index_info_text_view);
        hnswIndexResultsContainer = findViewById(R.id.hnsw_index_results_container);
        hnswIndexResultsRecyclerView = findViewById(R.id.hnsw_index_results_recycler_view);
        
        // Initialize values
        dimensionValue.setText(String.valueOf(dimension));
        metricRadioGroup.check(R.id.metric_l2);
        hnswMValue.setText(String.valueOf(hnswM));
        hnswEfConstructionValue.setText(String.valueOf(hnswEfConstruction));
        searchKValue.setText(String.valueOf(searchK));
        
        // efSearchSeekBar and efSearchValue are not present in the XML layout
        // Using default value of 50 for efSearch
        
        // Setup RecyclerViews
        vectorStoreResultsRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        vectorStoreResultsRecyclerView.setAdapter(new SearchResultsAdapter(new ArrayList<>()));
        
        hnswIndexResultsRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        hnswIndexResultsRecyclerView.setAdapter(new SearchResultsAdapter(new ArrayList<>()));
        
        // MMapVectorStore UI elements
        mmapFilePathEditText = findViewById(R.id.mmap_file_path_edit_text);
        // Set default file path to internal storage (no permissions needed)
        String defaultFilePath = getFilesDir().getAbsolutePath() + "/vectorstore.mmap";
        mmapFilePathEditText.setText(defaultFilePath);
        createMMapVectorStoreButton = findViewById(R.id.create_mmap_vector_store_button);
        openMMapVectorStoreButton = findViewById(R.id.open_mmap_vector_store_button);
        searchMMapVectorStoreButton = findViewById(R.id.search_mmap_vector_store_button);
        releaseMMapVectorStoreButton = findViewById(R.id.release_mmap_vector_store_button);
        mmapVectorStoreInfoTextView = findViewById(R.id.mmap_vector_store_info_text_view);
        mmapVectorStoreResultsContainer = findViewById(R.id.mmap_vector_store_results_container);
        mmapVectorStoreResultsRecyclerView = findViewById(R.id.mmap_vector_store_results_recycler_view);
        
        // Setup MMapVectorStore RecyclerView
        mmapVectorStoreResultsRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        mmapVectorStoreResultsRecyclerView.setAdapter(new SearchResultsAdapter(new ArrayList<>()));
        

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
                if (checkedId == R.id.metric_l2) {
                    selectedMetric = DistanceMetric.L2;
                } else if (checkedId == R.id.metric_cosine) {
                    selectedMetric = DistanceMetric.COSINE;
                } else if (checkedId == R.id.metric_dot) {
                    selectedMetric = DistanceMetric.DOT;
                } else {
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
        
        // efSearchSeekBar is not present in the XML layout
        // Using default value of 50 for efSearch
        
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
        
        // HNSW buttons not present in XML layout
        // setHNSWEfSearchButton
        // getHNSWEfSearchButton
        // containsVectorInHNSWButton
        // getVectorFromHNSWButton
        // getHNSWDimensionButton
        // getHNSWCapacityButton
        
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
        

        
        releaseMMapVectorStoreButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                releaseMMapVectorStore();
            }
        });
        
        createMMapVectorStoreButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                createMMapVectorStore();
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
        String storeStatus = vectorStoreHandle != 0 ? getString(R.string.status_created) : getString(R.string.none);
        vectorStoreInfoTextView.setText(getString(R.string.label_vector_store_status) + ": " + storeStatus + "\n" + getString(R.string.label_vector_count) + ": " + vectorStoreCount);
    }
    
    private void updateHNSWIndexInfo() {
        String indexStatus = hnswIndexHandle != 0 ? getString(R.string.status_created) : getString(R.string.none);
        hnswIndexInfoTextView.setText(getString(R.string.label_hnsw_index_status) + ": " + indexStatus + "\n" + getString(R.string.label_vector_count) + ": " + hnswIndexCount);
    }
    
    private void updateMMapVectorStoreInfo() {
        String storeStatus = mmapVectorStoreHandle != 0 ? getString(R.string.status_created) : getString(R.string.none);
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
                    if (vectorStoreHandle != 0) {
                        LlamaMobileVD.nativeVectorStoreDestroy(vectorStoreHandle);
                        vectorStoreHandle = 0;
                    }
                    
                    long newVectorStoreHandle = LlamaMobileVD.createVectorStore(dimension, selectedMetric);
                    vectorStoreHandle = newVectorStoreHandle;
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
        if (vectorStoreHandle == 0) {
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
                        LlamaMobileVD.nativeVectorStoreAddVector(vectorStoreHandle, (long) (i + 1), vector);
                    }
                    
                    long count = LlamaMobileVD.nativeVectorStoreGetSize(vectorStoreHandle);
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            vectorStoreCount = (int) count;
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
        if (vectorStoreHandle == 0) {
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
                    SearchResult[] results = LlamaMobileVD.nativeVectorStoreSearch(vectorStoreHandle, queryVector, searchK);
                    
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
        if (vectorStoreHandle == 0) {
            updateStatus(getString(R.string.status_please_create_vector_store_first));
            return;
        }
        
        updateStatus(getString(R.string.status_clearing_vector_store));
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    LlamaMobileVD.nativeVectorStoreClear(vectorStoreHandle);
                    
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
        if (vectorStoreHandle == 0) {
            updateStatus(getString(R.string.status_please_create_vector_store_first));
            return;
        }
        
        updateStatus(getString(R.string.status_releasing_vector_store));
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    LlamaMobileVD.nativeVectorStoreDestroy(vectorStoreHandle);
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            vectorStoreHandle = 0;
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
    

    
    // HNSWIndex operations
    private void createHNSWIndex() {
        updateStatus(getString(R.string.status_creating_hnsw_index));
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    // First close any existing HNSW index
                    if (hnswIndexHandle != 0) {
                        LlamaMobileVD.nativeHNSWIndexDestroy(hnswIndexHandle);
                        hnswIndexHandle = 0;
                    }
                    
                    int maxElements = 10000; // Adjust based on needs
                    long newHnswIndexHandle = LlamaMobileVD.createHNSWIndex(dimension, selectedMetric, maxElements, hnswM, hnswEfConstruction, 42);
                    hnswIndexHandle = newHnswIndexHandle;
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
        if (hnswIndexHandle == 0) {
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
                        LlamaMobileVD.nativeHNSWIndexAddVector(hnswIndexHandle, (long) (i + 1), vector);
                    }
                    
                    long count = LlamaMobileVD.nativeHNSWIndexGetSize(hnswIndexHandle);
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            hnswIndexCount = (int) count;
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
        if (hnswIndexHandle == 0) {
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
                    LlamaMobileVD.nativeHNSWIndexSetEfSearch(hnswIndexHandle, efSearch);
                    SearchResult[] results = LlamaMobileVD.nativeHNSWIndexSearch(hnswIndexHandle, queryVector, searchK);
                    
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
        if (hnswIndexHandle == 0) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first));
            return;
        }
        
        updateStatus(getString(R.string.status_clearing_hnsw_index));
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    // Note: HNSWIndex doesn't have a clear method in the current SDK
                    // We'll just recreate the index
                    LlamaMobileVD.nativeHNSWIndexDestroy(hnswIndexHandle);
                    int maxElements = 10000;
                    hnswIndexHandle = LlamaMobileVD.createHNSWIndex(dimension, selectedMetric, maxElements, hnswM, hnswEfConstruction, 42);
                    
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
        if (hnswIndexHandle == 0) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first));
            return;
        }
        
        updateStatus(getString(R.string.status_releasing_hnsw_index));
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    LlamaMobileVD.nativeHNSWIndexDestroy(hnswIndexHandle);
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            hnswIndexHandle = 0;
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
        if (hnswIndexHandle == 0) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first));
            return;
        }
        
        updateStatus("Setting HNSW efSearch...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    boolean success = LlamaMobileVD.nativeHNSWIndexSetEfSearch(hnswIndexHandle, efSearch);
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus(success ? "Successfully set HNSW efSearch to " + efSearch : "Failed to set HNSW efSearch");
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
        if (hnswIndexHandle == 0) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first));
            return;
        }
        
        updateStatus("Getting HNSW efSearch...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    int currentEfSearch = LlamaMobileVD.nativeHNSWIndexGetEfSearch(hnswIndexHandle);
                    
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
        if (hnswIndexHandle == 0) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first));
            return;
        }
        
        updateStatus("Checking if vector exists in HNSW...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    long vectorId = 1;
                    boolean contains = LlamaMobileVD.nativeHNSWIndexContains(hnswIndexHandle, vectorId);
                    
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
        if (hnswIndexHandle == 0) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first));
            return;
        }
        
        updateStatus("Getting vector from HNSW...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    long vectorId = 1;
                    float[] vector = LlamaMobileVD.nativeHNSWIndexGetVector(hnswIndexHandle, vectorId);
                    
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
        if (hnswIndexHandle == 0) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first));
            return;
        }
        
        updateStatus("Getting HNSW dimension...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    int dimension = LlamaMobileVD.nativeHNSWIndexGetDimension(hnswIndexHandle);
                    
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
        if (hnswIndexHandle == 0) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first));
            return;
        }
        
        updateStatus("Getting HNSW capacity...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    long capacity = LlamaMobileVD.nativeHNSWIndexGetCapacity(hnswIndexHandle);
                    
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
    private void createMMapVectorStore() {
        String filePath = mmapFilePathEditText.getText().toString().trim();
        if (filePath.isEmpty()) {
            updateStatus("Please enter a valid file path");
            return;
        }
        
        updateStatus("Creating MMapVectorStore...");
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    // Create a new MMapVectorStore builder
                    long builderHandle = LlamaMobileVD.createMMapVectorStoreBuilder(dimension, selectedMetric);
                    if (builderHandle == 0) {
                        throw new Exception("Failed to create MMapVectorStore builder");
                    }
                    
                    // Add 100 vectors to the builder
                    for (int i = 0; i < 100; i++) {
                        float[] vector = createRandomVector(dimension);
                        boolean added = LlamaMobileVD.nativeMMapVectorStoreBuilderAddVector(builderHandle, (long) (i + 1), vector);
                        if (!added) {
                            throw new Exception("Failed to add vector " + (i + 1));
                        }
                    }
                    
                    // Save the MMapVectorStore
                    boolean saved = LlamaMobileVD.nativeMMapVectorStoreBuilderSave(builderHandle, filePath);
                    if (!saved) {
                        throw new Exception("Failed to save MMapVectorStore");
                    }
                    
                    // Destroy the builder
                    LlamaMobileVD.nativeMMapVectorStoreBuilderDestroy(builderHandle);
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("MMapVectorStore created successfully with 100 vectors");
                        }
                    });
                } catch (Exception e) {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            updateStatus("Error creating MMapVectorStore: " + e.getMessage());
                        }
                    });
                }
            }
        }).start();
    }
    
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
                    if (mmapVectorStoreHandle != 0) {
                        LlamaMobileVD.nativeMMapVectorStoreClose(mmapVectorStoreHandle);
                        mmapVectorStoreHandle = 0;
                    }
                    
                    try {
                        // Try to open the existing store
                        long newMMapVectorStoreHandle = LlamaMobileVD.openMMapVectorStore(filePath);
                        if (newMMapVectorStoreHandle == 0) {
                            throw new Exception("Failed to open MMapVectorStore");
                        }
                        long count = LlamaMobileVD.nativeMMapVectorStoreGetSize(newMMapVectorStoreHandle);
                        
                        // If the store is empty, create a new one with vectors
                        if (count == 0) {
                            LlamaMobileVD.nativeMMapVectorStoreClose(newMMapVectorStoreHandle);
                            
                            // Create a new MMapVectorStore builder
                            long builderHandle = LlamaMobileVD.createMMapVectorStoreBuilder(dimension, selectedMetric);
                            if (builderHandle == 0) {
                                throw new Exception("Failed to create MMapVectorStore builder");
                            }
                            
                            // Add 100 vectors to the builder
                            for (int i = 0; i < 100; i++) {
                                float[] vector = createRandomVector(dimension);
                                boolean added = LlamaMobileVD.nativeMMapVectorStoreBuilderAddVector(builderHandle, (long) (i + 1), vector);
                                if (!added) {
                                    throw new Exception("Failed to add vector " + (i + 1));
                                }
                            }
                            
                            // Save the MMapVectorStore
                            boolean saved = LlamaMobileVD.nativeMMapVectorStoreBuilderSave(builderHandle, filePath);
                            if (!saved) {
                                throw new Exception("Failed to save MMapVectorStore");
                            }
                            
                            // Destroy the builder
                            LlamaMobileVD.nativeMMapVectorStoreBuilderDestroy(builderHandle);
                            
                            // Reopen the store
                            newMMapVectorStoreHandle = LlamaMobileVD.openMMapVectorStore(filePath);
                            if (newMMapVectorStoreHandle == 0) {
                                throw new Exception("Failed to reopen MMapVectorStore");
                            }
                            count = LlamaMobileVD.nativeMMapVectorStoreGetSize(newMMapVectorStoreHandle);
                        }
                        
                        mmapVectorStoreHandle = newMMapVectorStoreHandle;
                        mmapVectorStoreCount = (int) count;
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
                        // If opening fails (e.g., file doesn't exist), create a new store with vectors
                        long builderHandle = LlamaMobileVD.createMMapVectorStoreBuilder(dimension, selectedMetric);
                        if (builderHandle == 0) {
                            throw new Exception("Failed to create MMapVectorStore builder");
                        }
                        
                        // Add 100 vectors to the builder
                        for (int i = 0; i < 100; i++) {
                            float[] vector = createRandomVector(dimension);
                            boolean added = LlamaMobileVD.nativeMMapVectorStoreBuilderAddVector(builderHandle, (long) (i + 1), vector);
                            if (!added) {
                                throw new Exception("Failed to add vector " + (i + 1));
                            }
                        }
                        
                        // Save the MMapVectorStore
                        boolean saved = LlamaMobileVD.nativeMMapVectorStoreBuilderSave(builderHandle, filePath);
                        if (!saved) {
                            throw new Exception("Failed to save MMapVectorStore");
                        }
                        
                        // Destroy the builder
                        LlamaMobileVD.nativeMMapVectorStoreBuilderDestroy(builderHandle);
                        
                        // Open the newly created store
                        long newMMapVectorStoreHandle = LlamaMobileVD.openMMapVectorStore(filePath);
                        if (newMMapVectorStoreHandle == 0) {
                            throw new Exception("Failed to open newly created MMapVectorStore");
                        }
                        long count = LlamaMobileVD.nativeMMapVectorStoreGetSize(newMMapVectorStoreHandle);
                        
                        mmapVectorStoreHandle = newMMapVectorStoreHandle;
                        mmapVectorStoreCount = (int) count;
                        mmapVectorStoreResults.clear();
                        
                        handler.post(new Runnable() {
                            @Override
                            public void run() {
                                mmapVectorStoreResultsContainer.setVisibility(LinearLayout.GONE);
                                updateMMapVectorStoreInfo();
                                updateStatus(getString(R.string.status_mmap_vector_store_opened));
                            }
                        });
                    }
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
        if (mmapVectorStoreHandle == 0) {
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
                    int storeDimension = LlamaMobileVD.nativeMMapVectorStoreGetDimension(mmapVectorStoreHandle);
                    float[] queryVector = createRandomVector(storeDimension);
                    SearchResult[] results = LlamaMobileVD.nativeMMapVectorStoreSearch(mmapVectorStoreHandle, queryVector, searchK);
                    
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
    

    
    private void releaseMMapVectorStore() {
        if (mmapVectorStoreHandle == 0) {
            updateStatus(getString(R.string.status_please_open_mmap_vector_store_first));
            return;
        }
        
        updateStatus(getString(R.string.status_releasing_mmap_vector_store));
        
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    LlamaMobileVD.nativeMMapVectorStoreClose(mmapVectorStoreHandle);
                    
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            mmapVectorStoreHandle = 0;
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
                holder.textView.setText("ID: " + result.getId() + ", Distance: " + String.format("%.6f", result.getDistance()));
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
