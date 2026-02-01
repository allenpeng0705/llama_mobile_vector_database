package com.llamamobile.androidsdkexample

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.llamamobile.vd.LlamaMobileVD
import com.llamamobile.vd.LlamaMobileVD.SearchResult
import java.util.*

class MainActivity : AppCompatActivity() {
    // VectorStore state
    private var vectorStoreHandle: Long = 0
    private var vectorStoreCount = 0
    private var vectorStoreResults: List<SearchResult> = emptyList()
    
    // HNSWIndex state
    private var hnswIndexHandle: Long = 0
    private var hnswIndexCount = 0
    private var hnswIndexResults: List<SearchResult> = emptyList()
    
    // MMapVectorStore state
    private var mmapVectorStoreHandle: Long = 0
    private var mmapVectorStoreCount = 0
    private var mmapVectorStoreResults: List<SearchResult> = emptyList()
    
    // MMapVectorStoreBuilder state
    private var mmapVectorStoreBuilderHandle: Long = 0
    private var mmapVectorStoreBuilderCount = 0
    
    // Configuration state
    private var dimension = 128
    private var selectedMetric = 0 // 0 = L2, 1 = COSINE, 2 = DOT
    private var hnswM = 16
    private var hnswEfConstruction = 200
    private var searchK = 5
    private var efSearch = 50
    
    // UI elements
    private lateinit var statusTextView: TextView
    private lateinit var dimensionSeekBar: SeekBar
    private lateinit var dimensionValue: TextView
    private lateinit var metricRadioGroup: RadioGroup
    private lateinit var hnswMSeekBar: SeekBar
    private lateinit var hnswMValue: TextView
    private lateinit var hnswEfConstructionSeekBar: SeekBar
    private lateinit var hnswEfConstructionValue: TextView
    private lateinit var searchKSeekBar: SeekBar
    private lateinit var searchKValue: TextView
    
    private lateinit var createVectorStoreButton: Button
    private lateinit var addVectorsToStoreButton: Button
    private lateinit var searchVectorStoreButton: Button
    private lateinit var clearVectorStoreButton: Button
    private lateinit var releaseVectorStoreButton: Button
    private lateinit var vectorStoreInfoTextView: TextView
    private lateinit var vectorStoreResultsContainer: LinearLayout
    private lateinit var vectorStoreResultsRecyclerView: RecyclerView
    
    private lateinit var createHNSWIndexButton: Button
    private lateinit var addVectorsToHNSWButton: Button
    private lateinit var searchHNSWIndexButton: Button
    private lateinit var clearHNSWIndexButton: Button
    private lateinit var releaseHNSWIndexButton: Button
    private lateinit var hnswIndexInfoTextView: TextView
    private lateinit var hnswIndexResultsContainer: LinearLayout
    private lateinit var hnswIndexResultsRecyclerView: RecyclerView
    
    // MMapVectorStore UI elements
    private lateinit var mmapFilePathEditText: EditText
    private lateinit var createMMapVectorStoreButton: Button
    private lateinit var openMMapVectorStoreButton: Button
    private lateinit var searchMMapVectorStoreButton: Button
    private lateinit var releaseMMapVectorStoreButton: Button
    private lateinit var mmapVectorStoreInfoTextView: TextView
    private lateinit var mmapVectorStoreResultsContainer: LinearLayout
    private lateinit var mmapVectorStoreResultsRecyclerView: RecyclerView
    private lateinit var versionInfoTextView: TextView
    
    private val handler = Handler(Looper.getMainLooper())
    private val random = Random()
    
    private val STORAGE_PERMISSION_CODE = 101

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        requestStoragePermission()
        initializeUI()
        setupEventListeners()
        updateVectorStoreInfo()
        updateHNSWIndexInfo()
        updateMMapVectorStoreInfo()
    }

    private fun requestStoragePermission() {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
            if (checkSelfPermission(android.Manifest.permission.WRITE_EXTERNAL_STORAGE) != android.content.pm.PackageManager.PERMISSION_GRANTED) {
                requestPermissions(arrayOf(android.Manifest.permission.WRITE_EXTERNAL_STORAGE, android.Manifest.permission.READ_EXTERNAL_STORAGE), STORAGE_PERMISSION_CODE)
            }
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == STORAGE_PERMISSION_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == android.content.pm.PackageManager.PERMISSION_GRANTED) {
                updateStatus("Storage permission granted")
            } else {
                updateStatus("Storage permission denied. MMapVectorStore operations may fail.")
            }
        }
    }
    
    private fun initializeUI() {
        // Status
        statusTextView = findViewById(R.id.status_text_view)
        
        // Configuration
        dimensionSeekBar = findViewById(R.id.dimension_seek_bar)
        dimensionValue = findViewById(R.id.dimension_value)
        metricRadioGroup = findViewById(R.id.metric_radio_group)
        hnswMSeekBar = findViewById(R.id.hnsw_m_seek_bar)
        hnswMValue = findViewById(R.id.hnsw_m_value)
        hnswEfConstructionSeekBar = findViewById(R.id.hnsw_ef_construction_seek_bar)
        hnswEfConstructionValue = findViewById(R.id.hnsw_ef_construction_value)
        searchKSeekBar = findViewById(R.id.search_k_seek_bar)
        searchKValue = findViewById(R.id.search_k_value)
        
        // VectorStore
        createVectorStoreButton = findViewById(R.id.create_vector_store_button)
        addVectorsToStoreButton = findViewById(R.id.add_vectors_to_store_button)
        searchVectorStoreButton = findViewById(R.id.search_vector_store_button)
        clearVectorStoreButton = findViewById(R.id.clear_vector_store_button)
        releaseVectorStoreButton = findViewById(R.id.release_vector_store_button)
        vectorStoreInfoTextView = findViewById(R.id.vector_store_info_text_view)
        vectorStoreResultsContainer = findViewById(R.id.vector_store_results_container)
        vectorStoreResultsRecyclerView = findViewById(R.id.vector_store_results_recycler_view)
        
        // HNSWIndex
        createHNSWIndexButton = findViewById(R.id.create_hnsw_index_button)
        addVectorsToHNSWButton = findViewById(R.id.add_vectors_to_hnsw_button)
        searchHNSWIndexButton = findViewById(R.id.search_hnsw_index_button)
        clearHNSWIndexButton = findViewById(R.id.clear_hnsw_index_button)
        releaseHNSWIndexButton = findViewById(R.id.release_hnsw_index_button)
        hnswIndexInfoTextView = findViewById(R.id.hnsw_index_info_text_view)
        hnswIndexResultsContainer = findViewById(R.id.hnsw_index_results_container)
        hnswIndexResultsRecyclerView = findViewById(R.id.hnsw_index_results_recycler_view)
        
        // Initialize values
        dimensionValue.text = dimension.toString()
        metricRadioGroup.check(R.id.metric_l2)
        hnswMValue.text = hnswM.toString()
        hnswEfConstructionValue.text = hnswEfConstruction.toString()
        searchKValue.text = searchK.toString()
        
        // Setup RecyclerViews
        vectorStoreResultsRecyclerView.layoutManager = LinearLayoutManager(this)
        vectorStoreResultsRecyclerView.adapter = SearchResultsAdapter(emptyList())
        
        hnswIndexResultsRecyclerView.layoutManager = LinearLayoutManager(this)
        hnswIndexResultsRecyclerView.adapter = SearchResultsAdapter(emptyList())
        
        // MMapVectorStore UI elements
        mmapFilePathEditText = findViewById(R.id.mmap_file_path_edit_text)
        // Set default file path to internal storage (no permissions needed)
        val defaultFilePath = filesDir.absolutePath + "/vectorstore.mmap"
        mmapFilePathEditText.setText(defaultFilePath)
        createMMapVectorStoreButton = findViewById(R.id.create_mmap_vector_store_button)
        openMMapVectorStoreButton = findViewById(R.id.open_mmap_vector_store_button)
        searchMMapVectorStoreButton = findViewById(R.id.search_mmap_vector_store_button)
        releaseMMapVectorStoreButton = findViewById(R.id.release_mmap_vector_store_button)
        mmapVectorStoreInfoTextView = findViewById(R.id.mmap_vector_store_info_text_view)
        versionInfoTextView = findViewById(R.id.version_info_text_view)
        mmapVectorStoreResultsContainer = findViewById(R.id.mmap_vector_store_results_container)
        mmapVectorStoreResultsRecyclerView = findViewById(R.id.mmap_vector_store_results_recycler_view)
        
        // Setup MMapVectorStore RecyclerView
        mmapVectorStoreResultsRecyclerView.layoutManager = LinearLayoutManager(this)
        mmapVectorStoreResultsRecyclerView.adapter = SearchResultsAdapter(emptyList())
    }
    
    private fun setupEventListeners() {
        // Configuration listeners
        dimensionSeekBar.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                dimension = progress
                dimensionValue.text = progress.toString()
            }
            
            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })
        
        metricRadioGroup.setOnCheckedChangeListener { _, checkedId ->
            selectedMetric = when (checkedId) {
                R.id.metric_l2 -> 0
                R.id.metric_cosine -> 1
                R.id.metric_dot -> 2
                else -> 0
            }
        }
        
        hnswMSeekBar.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                hnswM = progress
                hnswMValue.text = progress.toString()
            }
            
            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })
        
        hnswEfConstructionSeekBar.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                hnswEfConstruction = progress
                hnswEfConstructionValue.text = progress.toString()
            }
            
            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })
        
        searchKSeekBar.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                searchK = progress
                searchKValue.text = progress.toString()
            }
            
            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })
        
        // VectorStore listeners
        createVectorStoreButton.setOnClickListener {
            createVectorStore()
        }
        
        addVectorsToStoreButton.setOnClickListener {
            addVectorsToStore()
        }
        
        searchVectorStoreButton.setOnClickListener {
            searchVectorStore()
        }
        
        clearVectorStoreButton.setOnClickListener {
            clearVectorStore()
        }
        
        releaseVectorStoreButton.setOnClickListener {
            releaseVectorStore()
        }
        
        // HNSWIndex listeners
        createHNSWIndexButton.setOnClickListener {
            createHNSWIndex()
        }
        
        addVectorsToHNSWButton.setOnClickListener {
            addVectorsToHNSW()
        }
        
        searchHNSWIndexButton.setOnClickListener {
            searchHNSWIndex()
        }
        
        clearHNSWIndexButton.setOnClickListener {
            clearHNSWIndex()
        }
        
        releaseHNSWIndexButton.setOnClickListener {
            releaseHNSWIndex()
        }
        
        // MMapVectorStore listeners
        createMMapVectorStoreButton.setOnClickListener {
            createMMapVectorStore()
        }
        
        openMMapVectorStoreButton.setOnClickListener {
            openMMapVectorStore()
        }
        
        searchMMapVectorStoreButton.setOnClickListener {
            searchMMapVectorStore()
        }
        
        releaseMMapVectorStoreButton.setOnClickListener {
            releaseMMapVectorStore()
        }
    }
    
    private fun updateStatus(message: String) {
        handler.post {
            statusTextView.text = message
        }
    }
    
    private fun createRandomVector(dimension: Int): FloatArray {
        return FloatArray(dimension) { random.nextFloat() * 2 - 1 }
    }
    
    private fun getMetricName(metricValue: Int): String {
        return when (metricValue) {
            0 -> "L2"
            1 -> "COSINE"
            2 -> "DOT"
            else -> "Unknown"
        }
    }
    
    private fun updateVectorStoreInfo() {
        val storeStatus = if (vectorStoreHandle != 0L) getString(R.string.status_vector_store_created) else getString(R.string.none)
        vectorStoreInfoTextView.text = "${getString(R.string.label_vector_store_status)}: $storeStatus\n${getString(R.string.label_vector_count)}: $vectorStoreCount"
    }
    
    private fun updateHNSWIndexInfo() {
        val indexStatus = if (hnswIndexHandle != 0L) getString(R.string.status_hnsw_index_created) else getString(R.string.none)
        hnswIndexInfoTextView.text = "${getString(R.string.label_hnsw_index_status)}: $indexStatus\n${getString(R.string.label_vector_count)}: $hnswIndexCount"
    }
    
    private fun updateMMapVectorStoreInfo() {
        val storeStatus = if (mmapVectorStoreHandle != 0L) getString(R.string.status_mmap_vector_store_opened) else getString(R.string.none)
        mmapVectorStoreInfoTextView.text = "${getString(R.string.label_mmap_vector_store_status)}: $storeStatus\n${getString(R.string.label_vector_count)}: $mmapVectorStoreCount"
    }
    
    // VectorStore operations
    private fun createVectorStore() {
        updateStatus(getString(R.string.status_creating_vector_store))
        
        Thread {
            try {
                // First close any existing vector store
                if (vectorStoreHandle != 0L) {
                    LlamaMobileVD.nativeVectorStoreDestroy(vectorStoreHandle)
                    vectorStoreHandle = 0L
                }
                
                val newVectorStoreHandle = LlamaMobileVD.nativeVectorStoreCreate(dimension, selectedMetric)
                vectorStoreHandle = newVectorStoreHandle
                vectorStoreCount = 0
                vectorStoreResults = emptyList()
                
                handler.post {
                    vectorStoreResultsContainer.visibility = LinearLayout.GONE
                    updateVectorStoreInfo()
                    updateStatus(getString(R.string.status_vector_store_created))
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error creating VectorStore: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun addVectorsToStore() {
        if (vectorStoreHandle == 0L) {
            updateStatus(getString(R.string.status_please_create_vector_store_first))
            return
        }
        
        updateStatus(getString(R.string.status_adding_vectors_to_store))
        
        Thread {
            try {
                for (i in 0 until 100) {
                    val vector = createRandomVector(dimension)
                    LlamaMobileVD.nativeVectorStoreAddVector(vectorStoreHandle, (i + 1).toLong(), vector)
                }
                
                val count = LlamaMobileVD.nativeVectorStoreGetSize(vectorStoreHandle)
                
                handler.post {
                    vectorStoreCount = count.toInt()
                    updateVectorStoreInfo()
                    updateStatus(getString(R.string.status_added_vectors_to_store))
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error adding vectors to VectorStore: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun searchVectorStore() {
        if (vectorStoreHandle == 0L) {
            updateStatus(getString(R.string.status_please_create_vector_store_first))
            return
        }
        
        if (vectorStoreCount == 0) {
            updateStatus(getString(R.string.status_please_add_vectors_to_vector_store_first))
            return
        }
        
        updateStatus(getString(R.string.status_searching_vector_store))
        
        Thread {
            try {
                val queryVector = createRandomVector(dimension)
                val results = LlamaMobileVD.nativeVectorStoreSearch(vectorStoreHandle, queryVector, searchK)
                
                handler.post {
                    vectorStoreResults = results.toList()
                    vectorStoreResultsRecyclerView.adapter = SearchResultsAdapter(results.toList())
                    vectorStoreResultsContainer.visibility = LinearLayout.VISIBLE
                    updateStatus(getString(R.string.status_search_completed))
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error searching VectorStore: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun clearVectorStore() {
        if (vectorStoreHandle == 0L) {
            updateStatus(getString(R.string.status_please_create_vector_store_first))
            return
        }
        
        updateStatus(getString(R.string.status_clearing_vector_store))
        
        Thread {
            try {
                LlamaMobileVD.nativeVectorStoreClear(vectorStoreHandle)
                
                handler.post {
                    vectorStoreCount = 0
                    vectorStoreResults = emptyList()
                    vectorStoreResultsContainer.visibility = LinearLayout.GONE
                    updateVectorStoreInfo()
                    updateStatus(getString(R.string.status_vector_store_cleared))
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error clearing VectorStore: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun releaseVectorStore() {
        if (vectorStoreHandle == 0L) {
            updateStatus(getString(R.string.status_please_create_vector_store_first))
            return
        }
        
        updateStatus(getString(R.string.status_releasing_vector_store))
        
        Thread {
            try {
                LlamaMobileVD.nativeVectorStoreDestroy(vectorStoreHandle)
                
                handler.post {
                    vectorStoreHandle = 0L
                    vectorStoreCount = 0
                    vectorStoreResults = emptyList()
                    vectorStoreResultsContainer.visibility = LinearLayout.GONE
                    updateVectorStoreInfo()
                    updateStatus(getString(R.string.status_vector_store_released))
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error releasing VectorStore: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun getVectorFromStore() {
        if (vectorStoreHandle == 0L) {
            updateStatus(getString(R.string.status_please_create_vector_store_first))
            return
        }
        
        updateStatus("Getting vector from VectorStore...")
        
        Thread {
            try {
                val vectorId = 1 // Get the first vector
                val vector = LlamaMobileVD.nativeVectorStoreGetVector(vectorStoreHandle, vectorId.toLong())
                
                handler.post {
                    updateStatus("Successfully retrieved vector with ID $vectorId, first value: ${vector?.get(0) ?: "null"}")
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error getting vector from VectorStore: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun updateVectorInStore() {
        if (vectorStoreHandle == 0L) {
            updateStatus(getString(R.string.status_please_create_vector_store_first))
            return
        }
        
        updateStatus("Updating vector in VectorStore...")
        
        Thread {
            try {
                val vectorId = 1L // Update the first vector
                val updatedVector = createRandomVector(dimension)
                val success = LlamaMobileVD.nativeVectorStoreUpdateVector(vectorStoreHandle, vectorId, updatedVector)
                
                handler.post {
                    updateStatus("Vector update ${if (success) "successful" else "failed"} for ID $vectorId")
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error updating vector in VectorStore: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun removeVectorFromStore() {
        if (vectorStoreHandle == 0L) {
            updateStatus(getString(R.string.status_please_create_vector_store_first))
            return
        }
        
        updateStatus("Removing vector from VectorStore...")
        
        Thread {
            try {
                val vectorId = 1L // Remove the first vector
                val success = LlamaMobileVD.nativeVectorStoreRemoveVector(vectorStoreHandle, vectorId)
                var count = 0L
                if (success) {
                    count = LlamaMobileVD.nativeVectorStoreGetSize(vectorStoreHandle)
                }
                
                handler.post {
                    vectorStoreCount = count.toInt()
                    updateVectorStoreInfo()
                    updateStatus(if (success) "Successfully removed vector with ID $vectorId" else "Failed to remove vector")
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error removing vector from VectorStore: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun containsVectorInStore() {
        if (vectorStoreHandle == 0L) {
            updateStatus(getString(R.string.status_please_create_vector_store_first))
            return
        }
        
        updateStatus("Checking if vector exists in VectorStore...")
        
        Thread {
            try {
                val vectorId = 1L
                val contains = LlamaMobileVD.nativeVectorStoreContains(vectorStoreHandle, vectorId)
                
                handler.post {
                    updateStatus("Vector with ID $vectorId ${if (contains) "exists" else "does not exist"} in VectorStore")
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error checking vector existence: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun reserveVectorStore() {
        if (vectorStoreHandle == 0L) {
            updateStatus(getString(R.string.status_please_create_vector_store_first))
            return
        }
        
        updateStatus("Reserving space in VectorStore...")
        
        Thread {
            try {
                val reserveSize = 200L
                val success = LlamaMobileVD.nativeVectorStoreReserve(vectorStoreHandle, reserveSize)
                
                handler.post {
                    updateStatus("Space reservation ${if (success) "successful" else "failed"} for $reserveSize vectors in VectorStore")
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error reserving space in VectorStore: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun getVectorStoreDimension() {
        if (vectorStoreHandle == 0L) {
            updateStatus(getString(R.string.status_please_create_vector_store_first))
            return
        }
        
        updateStatus("Getting VectorStore dimension...")
        
        Thread {
            try {
                val storeDimension = LlamaMobileVD.nativeVectorStoreGetDimension(vectorStoreHandle)
                
                handler.post {
                    updateStatus("VectorStore dimension: $storeDimension")
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error getting VectorStore dimension: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun getVectorStoreMetric() {
        if (vectorStoreHandle == 0L) {
            updateStatus(getString(R.string.status_please_create_vector_store_first))
            return
        }
        
        updateStatus("Getting VectorStore distance metric...")
        
        Thread {
            try {
                val metricValue = LlamaMobileVD.nativeVectorStoreGetMetric(vectorStoreHandle)
                val metric = getMetricName(metricValue)
                
                handler.post {
                    updateStatus("VectorStore distance metric: $metric")
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error getting VectorStore metric: ${e.message}")
                }
            }
        }.start()
    }
    
    // HNSWIndex operations
    private fun createHNSWIndex() {
        updateStatus(getString(R.string.status_creating_hnsw_index))
        
        Thread {
            try {
                // First close any existing HNSW index
                if (hnswIndexHandle != 0L) {
                    LlamaMobileVD.nativeHNSWIndexDestroy(hnswIndexHandle)
                    hnswIndexHandle = 0L
                }
                
                val newHNSWIndexHandle = LlamaMobileVD.nativeHNSWIndexCreateWithParams(dimension, selectedMetric, 1000, hnswM, hnswEfConstruction, 42)
                hnswIndexHandle = newHNSWIndexHandle
                hnswIndexCount = 0
                hnswIndexResults = emptyList()
                
                handler.post {
                    hnswIndexResultsContainer.visibility = LinearLayout.GONE
                    updateHNSWIndexInfo()
                    updateStatus(getString(R.string.status_hnsw_index_created))
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error creating HNSWIndex: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun addVectorsToHNSW() {
        if (hnswIndexHandle == 0L) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first))
            return
        }
        
        updateStatus(getString(R.string.status_adding_vectors_to_hnsw))
        
        Thread {
            try {
                for (i in 0 until 100) {
                    val vector = createRandomVector(dimension)
                    LlamaMobileVD.nativeHNSWIndexAddVector(hnswIndexHandle, (i + 1).toLong(), vector)
                }
                
                val count = LlamaMobileVD.nativeHNSWIndexGetSize(hnswIndexHandle)
                
                handler.post {
                    hnswIndexCount = count.toInt()
                    updateHNSWIndexInfo()
                    updateStatus(getString(R.string.status_added_vectors_to_hnsw))
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error adding vectors to HNSWIndex: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun searchHNSWIndex() {
        if (hnswIndexHandle == 0L) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first))
            return
        }
        
        if (hnswIndexCount == 0) {
            updateStatus(getString(R.string.status_please_add_vectors_to_hnsw_index_first))
            return
        }
        
        updateStatus(getString(R.string.status_searching_hnsw_index))
        
        Thread {
            try {
                val queryVector = createRandomVector(dimension)
                LlamaMobileVD.nativeHNSWIndexSetEfSearch(hnswIndexHandle, efSearch)
                val results = LlamaMobileVD.nativeHNSWIndexSearch(hnswIndexHandle, queryVector, searchK)
                
                handler.post {
                    hnswIndexResults = results.toList()
                    hnswIndexResultsRecyclerView.adapter = SearchResultsAdapter(results.toList())
                    hnswIndexResultsContainer.visibility = LinearLayout.VISIBLE
                    updateStatus(getString(R.string.status_search_completed))
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error searching HNSWIndex: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun clearHNSWIndex() {
        if (hnswIndexHandle == 0L) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first))
            return
        }
        
        updateStatus(getString(R.string.status_clearing_hnsw_index))
        
        Thread {
            try {
                // Close and recreate the index to clear it
                LlamaMobileVD.nativeHNSWIndexDestroy(hnswIndexHandle)
                val newHNSWIndexHandle = LlamaMobileVD.nativeHNSWIndexCreateWithParams(dimension, selectedMetric, 1000, hnswM, hnswEfConstruction, 42)
                hnswIndexHandle = newHNSWIndexHandle
                
                handler.post {
                    hnswIndexCount = 0
                    hnswIndexResults = emptyList()
                    hnswIndexResultsContainer.visibility = LinearLayout.GONE
                    updateHNSWIndexInfo()
                    updateStatus(getString(R.string.status_hnsw_index_cleared))
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error clearing HNSWIndex: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun releaseHNSWIndex() {
        if (hnswIndexHandle == 0L) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first))
            return
        }
        
        updateStatus(getString(R.string.status_releasing_hnsw_index))
        
        Thread {
            try {
                LlamaMobileVD.nativeHNSWIndexDestroy(hnswIndexHandle)
                
                handler.post {
                    hnswIndexHandle = 0L
                    hnswIndexCount = 0
                    hnswIndexResults = emptyList()
                    hnswIndexResultsContainer.visibility = LinearLayout.GONE
                    updateHNSWIndexInfo()
                    updateStatus(getString(R.string.status_hnsw_index_released))
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error releasing HNSWIndex: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun setHNSWEfSearch() {
        if (hnswIndexHandle == 0L) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first))
            return
        }
        
        updateStatus("Setting HNSW efSearch...")
        
        Thread {
            try {
                val success = LlamaMobileVD.nativeHNSWIndexSetEfSearch(hnswIndexHandle, efSearch)
                
                handler.post {
                    updateStatus("Successfully set HNSW efSearch to $efSearch")
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error setting HNSW efSearch: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun getHNSWEfSearch() {
        if (hnswIndexHandle == 0L) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first))
            return
        }
        
        updateStatus("Getting HNSW efSearch...")
        
        Thread {
            try {
                val currentEfSearch = LlamaMobileVD.nativeHNSWIndexGetEfSearch(hnswIndexHandle)
                
                handler.post {
                    updateStatus("HNSW efSearch: $currentEfSearch")
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error getting HNSW efSearch: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun containsVectorInHNSW() {
        if (hnswIndexHandle == 0L) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first))
            return
        }
        
        updateStatus("Checking if vector exists in HNSW...")
        
        Thread {
            try {
                val vectorId = 1L
                val contains = LlamaMobileVD.nativeHNSWIndexContains(hnswIndexHandle, vectorId)
                
                handler.post {
                    updateStatus("Vector with ID $vectorId ${if (contains) "exists" else "does not exist"} in HNSW")
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error checking vector existence in HNSW: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun getVectorFromHNSW() {
        if (hnswIndexHandle == 0L) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first))
            return
        }
        
        updateStatus("Getting vector from HNSW...")
        
        Thread {
            try {
                val vectorId = 1L
                val vector = LlamaMobileVD.nativeHNSWIndexGetVector(hnswIndexHandle, vectorId)
                
                handler.post {
                    updateStatus("Successfully retrieved vector with ID $vectorId from HNSW, first value: ${vector?.get(0) ?: "null"}")
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error getting vector from HNSW: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun getHNSWDimension() {
        if (hnswIndexHandle == 0L) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first))
            return
        }
        
        updateStatus("Getting HNSW dimension...")
        
        Thread {
            try {
                val dimension = LlamaMobileVD.nativeHNSWIndexGetDimension(hnswIndexHandle)
                
                handler.post {
                    updateStatus("HNSW dimension: $dimension")
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error getting HNSW dimension: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun getHNSWCapacity() {
        if (hnswIndexHandle == 0L) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first))
            return
        }
        
        updateStatus("Getting HNSW capacity...")
        
        Thread {
            try {
                val capacity = LlamaMobileVD.nativeHNSWIndexGetCapacity(hnswIndexHandle)
                
                handler.post {
                    updateStatus("HNSW capacity: $capacity")
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error getting HNSW capacity: ${e.message}")
                }
            }
        }.start()
    }
    
    // MMapVectorStore operations
    private fun openMMapVectorStore() {
        val filePath = mmapFilePathEditText.text.toString().trim()
        if (filePath.isEmpty()) {
            updateStatus("Please enter a valid file path")
            return
        }
        
        updateStatus(getString(R.string.status_opening_mmap_vector_store))
        
        Thread {
            try {
                // First close any existing MMapVectorStore
                if (mmapVectorStoreHandle != 0L) {
                    LlamaMobileVD.nativeMMapVectorStoreClose(mmapVectorStoreHandle)
                    mmapVectorStoreHandle = 0L
                }
                
                var newMMapVectorStoreHandle = LlamaMobileVD.openMMapVectorStore(filePath)
                var count = LlamaMobileVD.nativeMMapVectorStoreGetSize(newMMapVectorStoreHandle)
                
                if (count == 0L) {
                    // Close empty store
                    LlamaMobileVD.nativeMMapVectorStoreClose(newMMapVectorStoreHandle)
                    newMMapVectorStoreHandle = 0L
                    
                    // Create a new builder and add 100 vectors
                    val builderHandle = LlamaMobileVD.nativeMMapVectorStoreBuilderCreate(dimension, selectedMetric)
                    for (i in 0 until 100) {
                        val vector = createRandomVector(dimension)
                        LlamaMobileVD.nativeMMapVectorStoreBuilderAddVector(builderHandle, i.toLong(), vector)
                    }
                    
                    // Save the builder to file
                    LlamaMobileVD.nativeMMapVectorStoreBuilderSave(builderHandle, filePath)
                    LlamaMobileVD.nativeMMapVectorStoreBuilderDestroy(builderHandle)
                    
                    // Reopen the store
                    newMMapVectorStoreHandle = LlamaMobileVD.openMMapVectorStore(filePath)
                    count = LlamaMobileVD.nativeMMapVectorStoreGetSize(newMMapVectorStoreHandle)
                }
                
                mmapVectorStoreHandle = newMMapVectorStoreHandle
                mmapVectorStoreCount = count.toInt()
                mmapVectorStoreResults = emptyList()
                
                handler.post {
                    mmapVectorStoreResultsContainer.visibility = LinearLayout.GONE
                    updateMMapVectorStoreInfo()
                    updateStatus(getString(R.string.status_mmap_vector_store_opened))
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error opening MMapVectorStore: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun searchMMapVectorStore() {
        if (mmapVectorStoreHandle == 0L) {
            updateStatus(getString(R.string.status_please_open_mmap_vector_store_first))
            return
        }
        
        if (mmapVectorStoreCount == 0) {
            updateStatus("MMapVectorStore is empty")
            return
        }
        
        updateStatus(getString(R.string.status_searching_mmap_vector_store))
        
        Thread {
            try {
                // Get the dimension from the store
                val storeDimension = LlamaMobileVD.nativeMMapVectorStoreGetDimension(mmapVectorStoreHandle)
                val queryVector = createRandomVector(storeDimension)
                val results = LlamaMobileVD.nativeMMapVectorStoreSearch(mmapVectorStoreHandle, queryVector, searchK)
                
                handler.post {
                    mmapVectorStoreResults = results.toList()
                    mmapVectorStoreResultsRecyclerView.adapter = SearchResultsAdapter(results.toList())
                    mmapVectorStoreResultsContainer.visibility = LinearLayout.VISIBLE
                    updateStatus(getString(R.string.status_search_completed))
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error searching MMapVectorStore: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun getMMapVectorStoreCount() {
        if (mmapVectorStoreHandle == 0L) {
            updateStatus(getString(R.string.status_please_open_mmap_vector_store_first))
            return
        }
        
        updateStatus("Getting MMapVectorStore count...")
        
        Thread {
            try {
                val count = LlamaMobileVD.nativeMMapVectorStoreGetSize(mmapVectorStoreHandle)
                
                handler.post {
                    mmapVectorStoreCount = count.toInt()
                    updateMMapVectorStoreInfo()
                    updateStatus("MMapVectorStore count: $count")
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error getting MMapVectorStore count: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun getMMapVectorStoreDimension() {
        if (mmapVectorStoreHandle == 0L) {
            updateStatus(getString(R.string.status_please_open_mmap_vector_store_first))
            return
        }
        
        updateStatus("Getting MMapVectorStore dimension...")
        
        Thread {
            try {
                val dimension = LlamaMobileVD.nativeMMapVectorStoreGetDimension(mmapVectorStoreHandle)
                
                handler.post {
                    updateStatus("MMapVectorStore dimension: $dimension")
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error getting MMapVectorStore dimension: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun getMMapVectorStoreMetric() {
        if (mmapVectorStoreHandle == 0L) {
            updateStatus(getString(R.string.status_please_open_mmap_vector_store_first))
            return
        }
        
        updateStatus("Getting MMapVectorStore metric...")
        
        Thread {
            try {
                val metricValue = LlamaMobileVD.nativeMMapVectorStoreGetMetric(mmapVectorStoreHandle)
                val metric = getMetricName(metricValue)
                
                handler.post {
                    updateStatus("MMapVectorStore metric: $metric")
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error getting MMapVectorStore metric: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun releaseMMapVectorStore() {
        if (mmapVectorStoreHandle == 0L) {
            updateStatus(getString(R.string.status_please_open_mmap_vector_store_first))
            return
        }
        
        updateStatus(getString(R.string.status_releasing_mmap_vector_store))
        
        Thread {
            try {
                LlamaMobileVD.nativeMMapVectorStoreClose(mmapVectorStoreHandle)
                
                handler.post {
                    mmapVectorStoreHandle = 0L
                    mmapVectorStoreCount = 0
                    mmapVectorStoreResults = emptyList()
                    mmapVectorStoreResultsContainer.visibility = LinearLayout.GONE
                    updateMMapVectorStoreInfo()
                    updateStatus(getString(R.string.status_mmap_vector_store_released))
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error releasing MMapVectorStore: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun createMMapVectorStore() {
        updateStatus("Creating MMapVectorStore...")
        
        Thread {
            try {
                val filePath = mmapFilePathEditText.text.toString()
                
                // Create a builder
                val builderId = LlamaMobileVD.nativeMMapVectorStoreBuilderCreate(dimension, selectedMetric)
                
                // Add some sample vectors
                for (i in 0 until 100) {
                    val vector = createRandomVector(dimension)
                    LlamaMobileVD.nativeMMapVectorStoreBuilderAddVector(builderId, (i + 1).toLong(), vector)
                }
                
                // Save the builder to create the MMapVectorStore
                val saved = LlamaMobileVD.nativeMMapVectorStoreBuilderSave(builderId, filePath)
                
                // Destroy the builder
                LlamaMobileVD.nativeMMapVectorStoreBuilderDestroy(builderId)
                
                handler.post {
                    if (saved) {
                        updateStatus("MMapVectorStore created successfully at $filePath")
                    } else {
                        updateStatus("Failed to create MMapVectorStore")
                    }
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error creating MMapVectorStore: ${e.message}")
                }
            }
        }.start()
    }
    
    // MMapVectorStoreBuilder operations
    private fun createMMapVectorStoreBuilder() {
        updateStatus("Creating MMapVectorStoreBuilder...")
        
        Thread {
            try {
                // First close any existing builder
                if (mmapVectorStoreBuilderHandle != 0L) {
                    LlamaMobileVD.nativeMMapVectorStoreBuilderDestroy(mmapVectorStoreBuilderHandle)
                    mmapVectorStoreBuilderHandle = 0L
                }
                
                val newBuilderHandle = LlamaMobileVD.nativeMMapVectorStoreBuilderCreate(dimension, selectedMetric)
                mmapVectorStoreBuilderHandle = newBuilderHandle
                mmapVectorStoreBuilderCount = 0
                
                handler.post {
                    updateStatus("MMapVectorStoreBuilder created successfully")
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error creating MMapVectorStoreBuilder: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun addVectorsToBuilder() {
        if (mmapVectorStoreBuilderHandle == 0L) {
            updateStatus("Please create MMapVectorStoreBuilder first")
            return
        }
        
        updateStatus("Adding vectors to MMapVectorStoreBuilder...")
        
        Thread {
            try {
                for (i in 0 until 100) {
                    val vector = createRandomVector(dimension)
                    LlamaMobileVD.nativeMMapVectorStoreBuilderAddVector(mmapVectorStoreBuilderHandle, (mmapVectorStoreBuilderCount + i + 1).toLong(), vector)
                }
                
                val count = LlamaMobileVD.nativeMMapVectorStoreBuilderGetSize(mmapVectorStoreBuilderHandle)
                
                handler.post {
                    mmapVectorStoreBuilderCount = count.toInt()
                    updateStatus("Added 100 vectors to MMapVectorStoreBuilder. Total: $count")
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error adding vectors to MMapVectorStoreBuilder: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun saveMMapVectorStore() {
        val filePath = mmapFilePathEditText.text.toString().trim()
        if (filePath.isEmpty()) {
            updateStatus("Please enter a valid file path")
            return
        }
        
        if (mmapVectorStoreBuilderHandle == 0L) {
            updateStatus("Please create MMapVectorStoreBuilder first")
            return
        }
        
        updateStatus("Saving MMapVectorStore to file...")
        
        Thread {
            try {
                LlamaMobileVD.nativeMMapVectorStoreBuilderSave(mmapVectorStoreBuilderHandle, filePath)
                
                handler.post {
                    updateStatus("MMapVectorStore saved successfully to $filePath")
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error saving MMapVectorStore: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun clearMMapVectorStoreBuilder() {
        if (mmapVectorStoreBuilderHandle == 0L) {
            updateStatus("Please create MMapVectorStoreBuilder first")
            return
        }
        
        updateStatus("Clearing MMapVectorStoreBuilder...")
        
        Thread {
            try {
                LlamaMobileVD.nativeMMapVectorStoreBuilderDestroy(mmapVectorStoreBuilderHandle)
                val newBuilderHandle = LlamaMobileVD.nativeMMapVectorStoreBuilderCreate(dimension, selectedMetric)
                mmapVectorStoreBuilderHandle = newBuilderHandle
                
                handler.post {
                    mmapVectorStoreBuilderCount = 0
                    updateStatus("MMapVectorStoreBuilder cleared successfully")
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error clearing MMapVectorStoreBuilder: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun releaseMMapVectorStoreBuilder() {
        if (mmapVectorStoreBuilderHandle == 0L) {
            updateStatus("Please create MMapVectorStoreBuilder first")
            return
        }
        
        updateStatus("Releasing MMapVectorStoreBuilder...")
        
        Thread {
            try {
                LlamaMobileVD.nativeMMapVectorStoreBuilderDestroy(mmapVectorStoreBuilderHandle)
                
                handler.post {
                    mmapVectorStoreBuilderHandle = 0L
                    mmapVectorStoreBuilderCount = 0
                    updateStatus("MMapVectorStoreBuilder released successfully")
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error releasing MMapVectorStoreBuilder: ${e.message}")
                }
            }
        }.start()
    }
    
    // Version operations
    private fun getVersion() {
        updateStatus("Getting SDK version...")
        
        Thread {
            try {
                val version = LlamaMobileVD.getVersion()
                
                handler.post {
                    versionInfoTextView.text = "Version: $version"
                    updateStatus("Successfully retrieved SDK version")
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error getting version: ${e.message}")
                }
            }
        }.start()
    }
    
    private fun getVersionDetailed() {
        updateStatus("Getting detailed SDK version...")
        
        Thread {
            try {
                val version = LlamaMobileVD.getVersion()
                val major = LlamaMobileVD.getVersionMajor()
                val minor = LlamaMobileVD.getVersionMinor()
                val patch = LlamaMobileVD.getVersionPatch()
                
                handler.post {
                    versionInfoTextView.text = "Version: $version\nMajor: $major\nMinor: $minor\nPatch: $patch"
                    updateStatus("Successfully retrieved detailed SDK version")
                }
            } catch (e: Exception) {
                handler.post {
                    updateStatus("Error getting detailed version: ${e.message}")
                }
            }
        }.start()
    }
    
    // Search Results Adapter
    inner class SearchResultsAdapter(private val results: List<SearchResult>) : RecyclerView.Adapter<SearchResultsAdapter.ViewHolder>() {
        
        inner class ViewHolder(itemView: android.view.View) : RecyclerView.ViewHolder(itemView) {
            val vectorIndexTextView: TextView = itemView.findViewById(android.R.id.text1)
            val distanceTextView: TextView = itemView.findViewById(android.R.id.text2)
        }
        
        override fun onCreateViewHolder(parent: android.view.ViewGroup, viewType: Int): ViewHolder {
            val itemView = android.view.LayoutInflater.from(parent.context)
                .inflate(android.R.layout.simple_list_item_2, parent, false)
            return ViewHolder(itemView)
        }
        
        override fun onBindViewHolder(holder: ViewHolder, position: Int) {
            val result = results[position]
            holder.vectorIndexTextView.text = "Vector ID: ${result.id}"
            holder.distanceTextView.text = "Distance: ${result.distance.format(6)}"
            holder.distanceTextView.setTextColor(ContextCompat.getColor(holder.itemView.context, android.R.color.darker_gray))
        }
        
        override fun getItemCount() = results.size
    }
    
    // Extension function to format float to fixed decimal places
    private fun Float.format(digits: Int) = java.lang.String.format("%.${digits}f", this)
}
