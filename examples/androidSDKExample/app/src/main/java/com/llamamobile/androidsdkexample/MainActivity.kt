package com.llamamobile.androidsdkexample

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.llamamobile.vd.VectorStore
import com.llamamobile.vd.HNSWIndex
import com.llamamobile.vd.DistanceMetric
import com.llamamobile.vd.SearchResult
import java.util.*

class MainActivity : AppCompatActivity() {
    // Vector Store state
    private var vectorStore: VectorStore? = null
    private var vectorStoreCount: Int = 0
    private var vectorStoreResults: List<SearchResult> = emptyList()
    
    // HNSW Index state
    private var hnswIndex: HNSWIndex? = null
    private var hnswIndexCount: Int = 0
    private var hnswIndexResults: List<SearchResult> = emptyList()
    
    // Configuration state
    private var dimension: Int = 128
    private var selectedMetric: DistanceMetric = DistanceMetric.L2
    private var hnswM: Int = 16
    private var hnswEfConstruction: Int = 200
    private var searchK: Int = 5
    private var efSearch: Int = 50
    
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
    private lateinit var efSearchSeekBar: SeekBar
    private lateinit var efSearchValue: TextView
    
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
    
    private val handler = Handler(Looper.getMainLooper())
    private val random = Random()
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        initializeUI()
        setupEventListeners()
        updateVectorStoreInfo()
        updateHNSWIndexInfo()
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
        efSearchSeekBar = findViewById(R.id.ef_search_seek_bar)
        efSearchValue = findViewById(R.id.ef_search_value)
        
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
        efSearchValue.text = efSearch.toString()
        
        // Initialize efSearch seekbar
        efSearchSeekBar.max = 200
        efSearchSeekBar.progress = efSearch
        
        // Setup RecyclerViews
        vectorStoreResultsRecyclerView.layoutManager = LinearLayoutManager(this)
        vectorStoreResultsRecyclerView.adapter = SearchResultsAdapter(emptyList())
        
        hnswIndexResultsRecyclerView.layoutManager = LinearLayoutManager(this)
        hnswIndexResultsRecyclerView.adapter = SearchResultsAdapter(emptyList())
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
        
        metricRadioGroup.setOnCheckedChangeListener { group, checkedId ->
            selectedMetric = when (checkedId) {
                R.id.metric_l2 -> DistanceMetric.L2
                R.id.metric_cosine -> DistanceMetric.COSINE
                R.id.metric_dot -> DistanceMetric.DOT
                else -> DistanceMetric.L2
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
        
        // efSearch seekbar listener
        efSearchSeekBar.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                efSearch = progress
                efSearchValue.text = progress.toString()
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
    }
    
    private fun updateStatus(message: String) {
        handler.post {
            statusTextView.text = message
        }
    }
    
    private fun createRandomVector(dimension: Int): FloatArray {
        return FloatArray(dimension) { random.nextFloat() * 2 - 1 }
    }
    
    private fun updateVectorStoreInfo() {
        val storeStatus = if (vectorStore != null) getString(R.string.status_created) else getString(R.string.none)
        vectorStoreInfoTextView.text = "${getString(R.string.label_vector_store_status)}: $storeStatus\n${getString(R.string.label_vector_count)}: $vectorStoreCount"
    }
    
    private fun updateHNSWIndexInfo() {
        val indexStatus = if (hnswIndex != null) getString(R.string.status_created) else getString(R.string.none)
        hnswIndexInfoTextView.text = "${getString(R.string.label_hnsw_index_status)}: $indexStatus\n${getString(R.string.label_vector_count)}: $hnswIndexCount"
    }
    
    // VectorStore operations
    private fun createVectorStore() {
        updateStatus(getString(R.string.status_creating_vector_store))
        
        Thread {
            try {
                // First close any existing vector store
                vectorStore?.close()
                
                val newVectorStore = VectorStore(dimension, selectedMetric)
                vectorStore = newVectorStore
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
        if (vectorStore == null) {
            updateStatus(getString(R.string.status_please_create_vector_store_first))
            return
        }
        
        updateStatus(getString(R.string.status_adding_vectors_to_store))
        
        Thread {
            try {
                for (i in 0 until 100) {
                    val vector = createRandomVector(dimension)
                    vectorStore!!.addVector(vector, i + 1)
                }
                
                val count = vectorStore!!.getCount()
                
                handler.post {
                    vectorStoreCount = count
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
        if (vectorStore == null) {
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
                val results = vectorStore!!.search(queryVector, searchK)
                
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
        if (vectorStore == null) {
            updateStatus(getString(R.string.status_please_create_vector_store_first))
            return
        }
        
        updateStatus(getString(R.string.status_clearing_vector_store))
        
        Thread {
            try {
                vectorStore!!.clear()
                
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
        if (vectorStore == null) {
            updateStatus(getString(R.string.status_please_create_vector_store_first))
            return
        }
        
        updateStatus(getString(R.string.status_releasing_vector_store))
        
        Thread {
            try {
                vectorStore!!.close()
                
                handler.post {
                    vectorStore = null
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
    
    // HNSWIndex operations
    private fun createHNSWIndex() {
        updateStatus(getString(R.string.status_creating_hnsw_index))
        
        Thread {
            try {
                // First close any existing HNSW index
                hnswIndex?.close()
                
                val newHnswIndex = HNSWIndex(dimension, selectedMetric, hnswM, hnswEfConstruction)
                hnswIndex = newHnswIndex
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
        if (hnswIndex == null) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first))
            return
        }
        
        updateStatus(getString(R.string.status_adding_vectors_to_hnsw))
        
        Thread {
            try {
                for (i in 0 until 100) {
                    val vector = createRandomVector(dimension)
                    hnswIndex!!.addVector(vector, i + 1)
                }
                
                val count = hnswIndex!!.getCount()
                
                handler.post {
                    hnswIndexCount = count
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
        if (hnswIndex == null) {
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
                val results = hnswIndex!!.search(queryVector, searchK, efSearch)
                
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
        if (hnswIndex == null) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first))
            return
        }
        
        updateStatus(getString(R.string.status_clearing_hnsw_index))
        
        Thread {
            try {
                hnswIndex!!.clear()
                
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
        if (hnswIndex == null) {
            updateStatus(getString(R.string.status_please_create_hnsw_index_first))
            return
        }
        
        updateStatus(getString(R.string.status_releasing_hnsw_index))
        
        Thread {
            try {
                hnswIndex!!.close()
                
                handler.post {
                    hnswIndex = null
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
            holder.distanceTextView.setTextColor(android.R.color.darker_gray)
        }
        
        override fun getItemCount() = results.size
    }
    
    // Extension function to format float to fixed decimal places
    private fun Float.format(digits: Int) = java.lang.String.format("%.${digits}f", this)
}
