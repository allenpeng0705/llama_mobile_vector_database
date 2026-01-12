import UIKit
import LlamaMobileVD

class MainViewController: UIViewController {
    // Vector Store state
    private var vectorStore: VectorStore?
    private var vectorStoreCount: Int = 0
    private var vectorStoreResults: [SearchResult] = []
    
    // HNSW Index state
    private var hnswIndex: HNSWIndex?
    private var hnswIndexCount: Int = 0
    private var hnswIndexResults: [SearchResult] = []
    
    // MMapVectorStore state
    private var mmapVectorStore: MMapVectorStore?
    private var mmapVectorStoreCount: Int = 0
    private var mmapVectorStoreDimension: Int = 0
    private var mmapVectorStoreMetric: String = ""
    private var mmapVectorStoreResults: [SearchResult] = []
    private var mmapFilePath: String = "/tmp/vectorstore.mmap"
    
    // Configuration state
    private var dimension: Int = 128
    private var selectedMetric: DistanceMetric = .l2
    private var hnswM: Int = 16
    private var hnswEfConstruction: Int = 200
    private var searchK: Int = 5
    private var efSearch: Int = 50
    
    // UI elements
    private let statusLabel = UILabel()
    private let dimensionSlider = UISlider()
    private let dimensionLabel = UILabel()
    private let metricSegmentedControl = UISegmentedControl(items: ["L2", "COSINE", "DOT"])
    private let hnswMSlider = UISlider()
    private let hnswMLabel = UILabel()
    private let hnswEfConstructionSlider = UISlider()
    private let hnswEfConstructionLabel = UILabel()
    private let searchKSlider = UISlider()
    private let searchKLabel = UILabel()
    private let efSearchSlider = UISlider()
    private let efSearchLabel = UILabel()
    
    private let createVectorStoreButton = UIButton(type: .system)
    private let addVectorsToStoreButton = UIButton(type: .system)
    private let searchVectorStoreButton = UIButton(type: .system)
    private let clearVectorStoreButton = UIButton(type: .system)
    private let releaseVectorStoreButton = UIButton(type: .system)
    private let vectorStoreInfoLabel = UILabel()
    private let vectorStoreResultsTableView = UITableView()
    
    private let createHNSWIndexButton = UIButton(type: .system)
    private let addVectorsToHNSWButton = UIButton(type: .system)
    private let searchHNSWIndexButton = UIButton(type: .system)
    private let clearHNSWIndexButton = UIButton(type: .system)
    private let releaseHNSWIndexButton = UIButton(type: .system)
    private let hnswIndexInfoLabel = UILabel()
    private let hnswIndexResultsTableView = UITableView()
    
    // MMapVectorStore UI elements
    private let mmapFilePathTextField = UITextField()
    private let openMMapVectorStoreButton = UIButton(type: .system)
    private let searchMMapVectorStoreButton = UIButton(type: .system)
    private let releaseMMapVectorStoreButton = UIButton(type: .system)
    private let mmapVectorStoreInfoLabel = UILabel()
    private let mmapVectorStoreResultsTableView = UITableView()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateStatus(message: "Ready")
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "LlamaMobileVD iOS Example"
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        var currentY: CGFloat = 16.0
        let horizontalPadding: CGFloat = 16.0
        let sectionSpacing: CGFloat = 24.0
        let elementSpacing: CGFloat = 8.0
        
        // Status label
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.numberOfLines = 0
        statusLabel.backgroundColor = UIColor(red: 0.94, green: 0.96, blue: 1.0, alpha: 1.0)
        statusLabel.layer.cornerRadius = 8
        statusLabel.clipsToBounds = true
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont.systemFont(ofSize: 16)
        statusLabel.textColor = .darkText
        statusLabel.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        contentView.addSubview(statusLabel)
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding)
        ])
        
        currentY += 60
        
        // Configuration section
        let configLabel = createSectionLabel(title: "Configuration")
        contentView.addSubview(configLabel)
        NSLayoutConstraint.activate([
            configLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            configLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            configLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding)
        ])
        
        currentY += 28
        
        // Dimension slider
        dimensionLabel.text = "Vector Dimension: \(dimension)"
        dimensionLabel.font = UIFont.systemFont(ofSize: 14)
        dimensionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(dimensionLabel)
        NSLayoutConstraint.activate([
            dimensionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            dimensionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding)
        ])
        
        currentY += 20
        
        dimensionSlider.minimumValue = 10
        dimensionSlider.maximumValue = 256
        dimensionSlider.value = Float(dimension)
        dimensionSlider.addTarget(self, action: #selector(dimensionSliderChanged(_:)), for: .valueChanged)
        dimensionSlider.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(dimensionSlider)
        NSLayoutConstraint.activate([
            dimensionSlider.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            dimensionSlider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            dimensionSlider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding)
        ])
        
        currentY += 40
        
        // Distance metric segmented control
        metricSegmentedControl.selectedSegmentIndex = 0
        metricSegmentedControl.addTarget(self, action: #selector(metricSegmentedControlChanged(_:)), for: .valueChanged)
        metricSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(metricSegmentedControl)
        NSLayoutConstraint.activate([
            metricSegmentedControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            metricSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            metricSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            metricSegmentedControl.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        currentY += 48
        
        // HNSW Parameters
        let hnswParamsLabel = createSectionLabel(title: "HNSW Parameters")
        contentView.addSubview(hnswParamsLabel)
        NSLayoutConstraint.activate([
            hnswParamsLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            hnswParamsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            hnswParamsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding)
        ])
        
        currentY += 28
        
        // HNSW M slider
        hnswMLabel.text = "M (Connections per node): \(hnswM)"
        hnswMLabel.font = UIFont.systemFont(ofSize: 14)
        hnswMLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(hnswMLabel)
        NSLayoutConstraint.activate([
            hnswMLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            hnswMLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding)
        ])
        
        currentY += 20
        
        hnswMSlider.minimumValue = 5
        hnswMSlider.maximumValue = 50
        hnswMSlider.value = Float(hnswM)
        hnswMSlider.addTarget(self, action: #selector(hnswMSliderChanged(_:)), for: .valueChanged)
        hnswMSlider.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(hnswMSlider)
        NSLayoutConstraint.activate([
            hnswMSlider.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            hnswMSlider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            hnswMSlider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding)
        ])
        
        currentY += 40
        
        // HNSW efConstruction slider
        hnswEfConstructionLabel.text = "efConstruction: \(hnswEfConstruction)"
        hnswEfConstructionLabel.font = UIFont.systemFont(ofSize: 14)
        hnswEfConstructionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(hnswEfConstructionLabel)
        NSLayoutConstraint.activate([
            hnswEfConstructionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            hnswEfConstructionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding)
        ])
        
        currentY += 20
        
        hnswEfConstructionSlider.minimumValue = 50
        hnswEfConstructionSlider.maximumValue = 500
        hnswEfConstructionSlider.value = Float(hnswEfConstruction)
        hnswEfConstructionSlider.addTarget(self, action: #selector(hnswEfConstructionSliderChanged(_:)), for: .valueChanged)
        hnswEfConstructionSlider.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(hnswEfConstructionSlider)
        NSLayoutConstraint.activate([
            hnswEfConstructionSlider.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            hnswEfConstructionSlider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            hnswEfConstructionSlider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding)
        ])
        
        currentY += 40
        
        // Search K slider
        searchKLabel.text = "Search k: \(searchK)"
        searchKLabel.font = UIFont.systemFont(ofSize: 14)
        searchKLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(searchKLabel)
        NSLayoutConstraint.activate([
            searchKLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            searchKLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding)
        ])
        
        currentY += 20
        
        searchKSlider.minimumValue = 1
        searchKSlider.maximumValue = 20
        searchKSlider.value = Float(searchK)
        searchKSlider.addTarget(self, action: #selector(searchKSliderChanged(_:)), for: .valueChanged)
        searchKSlider.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(searchKSlider)
        NSLayoutConstraint.activate([
            searchKSlider.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            searchKSlider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            searchKSlider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding)
        ])
        
        currentY += 40
        
        // efSearch slider
        efSearchLabel.text = "HNSW efSearch: \(efSearch)"
        efSearchLabel.font = UIFont.systemFont(ofSize: 14)
        efSearchLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(efSearchLabel)
        NSLayoutConstraint.activate([
            efSearchLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            efSearchLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding)
        ])
        
        currentY += 20
        
        efSearchSlider.minimumValue = 10
        efSearchSlider.maximumValue = 200
        efSearchSlider.value = Float(efSearch)
        efSearchSlider.addTarget(self, action: #selector(efSearchSliderChanged(_:)), for: .valueChanged)
        efSearchSlider.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(efSearchSlider)
        NSLayoutConstraint.activate([
            efSearchSlider.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            efSearchSlider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            efSearchSlider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding)
        ])
        
        currentY += sectionSpacing
        
        // VectorStore section
        let vectorStoreLabel = createSectionLabel(title: "VectorStore (Exact Search)")
        contentView.addSubview(vectorStoreLabel)
        NSLayoutConstraint.activate([
            vectorStoreLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            vectorStoreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding)
        ])
        
        currentY += 20
        
        // VectorStore buttons row 1
        let vectorStoreButtonsStackView1 = UIStackView()
        vectorStoreButtonsStackView1.axis = .horizontal
        vectorStoreButtonsStackView1.distribution = .fillEqually
        vectorStoreButtonsStackView1.spacing = 8
        vectorStoreButtonsStackView1.translatesAutoresizingMaskIntoConstraints = false
        
        createVectorStoreButton.setTitle("Create VectorStore", for: .normal)
        createVectorStoreButton.addTarget(self, action: #selector(createVectorStoreButtonTapped), for: .touchUpInside)
        createVectorStoreButton.backgroundColor = .systemBlue
        createVectorStoreButton.setTitleColor(.white, for: .normal)
        createVectorStoreButton.layer.cornerRadius = 8
        
        addVectorsToStoreButton.setTitle("Add 100 Vectors", for: .normal)
        addVectorsToStoreButton.addTarget(self, action: #selector(addVectorsToStoreButtonTapped), for: .touchUpInside)
        addVectorsToStoreButton.backgroundColor = .systemBlue
        addVectorsToStoreButton.setTitleColor(.white, for: .normal)
        addVectorsToStoreButton.layer.cornerRadius = 8
        
        vectorStoreButtonsStackView1.addArrangedSubview(createVectorStoreButton)
        vectorStoreButtonsStackView1.addArrangedSubview(addVectorsToStoreButton)
        
        contentView.addSubview(vectorStoreButtonsStackView1)
        NSLayoutConstraint.activate([
            vectorStoreButtonsStackView1.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            vectorStoreButtonsStackView1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            vectorStoreButtonsStackView1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            vectorStoreButtonsStackView1.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        currentY += 50
        
        // VectorStore buttons row 2
        let vectorStoreButtonsStackView2 = UIStackView()
        vectorStoreButtonsStackView2.axis = .horizontal
        vectorStoreButtonsStackView2.distribution = .fillEqually
        vectorStoreButtonsStackView2.spacing = 8
        vectorStoreButtonsStackView2.translatesAutoresizingMaskIntoConstraints = false
        
        searchVectorStoreButton.setTitle("Search", for: .normal)
        searchVectorStoreButton.addTarget(self, action: #selector(searchVectorStoreButtonTapped), for: .touchUpInside)
        searchVectorStoreButton.backgroundColor = .systemBlue
        searchVectorStoreButton.setTitleColor(.white, for: .normal)
        searchVectorStoreButton.layer.cornerRadius = 8
        
        clearVectorStoreButton.setTitle("Clear", for: .normal)
        clearVectorStoreButton.addTarget(self, action: #selector(clearVectorStoreButtonTapped), for: .touchUpInside)
        clearVectorStoreButton.backgroundColor = .systemBlue
        clearVectorStoreButton.setTitleColor(.white, for: .normal)
        clearVectorStoreButton.layer.cornerRadius = 8
        
        releaseVectorStoreButton.setTitle("Release", for: .normal)
        releaseVectorStoreButton.addTarget(self, action: #selector(releaseVectorStoreButtonTapped), for: .touchUpInside)
        releaseVectorStoreButton.backgroundColor = .systemBlue
        releaseVectorStoreButton.setTitleColor(.white, for: .normal)
        releaseVectorStoreButton.layer.cornerRadius = 8
        
        vectorStoreButtonsStackView2.addArrangedSubview(searchVectorStoreButton)
        vectorStoreButtonsStackView2.addArrangedSubview(clearVectorStoreButton)
        vectorStoreButtonsStackView2.addArrangedSubview(releaseVectorStoreButton)
        
        contentView.addSubview(vectorStoreButtonsStackView2)
        NSLayoutConstraint.activate([
            vectorStoreButtonsStackView2.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            vectorStoreButtonsStackView2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            vectorStoreButtonsStackView2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            vectorStoreButtonsStackView2.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        currentY += 40
        
        // VectorStore info
        vectorStoreInfoLabel.numberOfLines = 0
        vectorStoreInfoLabel.font = UIFont.systemFont(ofSize: 14)
        vectorStoreInfoLabel.text = "VectorStore ID: None\nVector count: 0"
        vectorStoreInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(vectorStoreInfoLabel)
        NSLayoutConstraint.activate([
            vectorStoreInfoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            vectorStoreInfoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding)
        ])
        
        currentY += 50
        
        // VectorStore results table
        vectorStoreResultsTableView.dataSource = self
        vectorStoreResultsTableView.delegate = self
        vectorStoreResultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ResultCell")
        vectorStoreResultsTableView.translatesAutoresizingMaskIntoConstraints = false
        vectorStoreResultsTableView.isHidden = true
        
        contentView.addSubview(vectorStoreResultsTableView)
        NSLayoutConstraint.activate([
            vectorStoreResultsTableView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            vectorStoreResultsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            vectorStoreResultsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            vectorStoreResultsTableView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        currentY += 220
        
        // HNSWIndex section
        let hnswIndexLabel = createSectionLabel(title: "HNSWIndex (Approximate Search)")
        contentView.addSubview(hnswIndexLabel)
        NSLayoutConstraint.activate([
            hnswIndexLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            hnswIndexLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding)
        ])
        
        currentY += 20
        
        // HNSWIndex buttons row 1
        let hnswButtonsStackView1 = UIStackView()
        hnswButtonsStackView1.axis = .horizontal
        hnswButtonsStackView1.distribution = .fillEqually
        hnswButtonsStackView1.spacing = 8
        hnswButtonsStackView1.translatesAutoresizingMaskIntoConstraints = false
        
        createHNSWIndexButton.setTitle("Create HNSWIndex", for: .normal)
        createHNSWIndexButton.addTarget(self, action: #selector(createHNSWIndexButtonTapped), for: .touchUpInside)
        createHNSWIndexButton.backgroundColor = .systemBlue
        createHNSWIndexButton.setTitleColor(.white, for: .normal)
        createHNSWIndexButton.layer.cornerRadius = 8
        
        addVectorsToHNSWButton.setTitle("Add 100 Vectors", for: .normal)
        addVectorsToHNSWButton.addTarget(self, action: #selector(addVectorsToHNSWButtonTapped), for: .touchUpInside)
        addVectorsToHNSWButton.backgroundColor = .systemBlue
        addVectorsToHNSWButton.setTitleColor(.white, for: .normal)
        addVectorsToHNSWButton.layer.cornerRadius = 8
        
        hnswButtonsStackView1.addArrangedSubview(createHNSWIndexButton)
        hnswButtonsStackView1.addArrangedSubview(addVectorsToHNSWButton)
        
        contentView.addSubview(hnswButtonsStackView1)
        NSLayoutConstraint.activate([
            hnswButtonsStackView1.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            hnswButtonsStackView1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            hnswButtonsStackView1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            hnswButtonsStackView1.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        currentY += 50
        
        // HNSWIndex buttons row 2
        let hnswButtonsStackView2 = UIStackView()
        hnswButtonsStackView2.axis = .horizontal
        hnswButtonsStackView2.distribution = .fillEqually
        hnswButtonsStackView2.spacing = 8
        hnswButtonsStackView2.translatesAutoresizingMaskIntoConstraints = false
        
        searchHNSWIndexButton.setTitle("Search", for: .normal)
        searchHNSWIndexButton.addTarget(self, action: #selector(searchHNSWIndexButtonTapped), for: .touchUpInside)
        searchHNSWIndexButton.backgroundColor = .systemBlue
        searchHNSWIndexButton.setTitleColor(.white, for: .normal)
        searchHNSWIndexButton.layer.cornerRadius = 8
        
        clearHNSWIndexButton.setTitle("Clear", for: .normal)
        clearHNSWIndexButton.addTarget(self, action: #selector(clearHNSWIndexButtonTapped), for: .touchUpInside)
        clearHNSWIndexButton.backgroundColor = .systemBlue
        clearHNSWIndexButton.setTitleColor(.white, for: .normal)
        clearHNSWIndexButton.layer.cornerRadius = 8
        
        releaseHNSWIndexButton.setTitle("Release", for: .normal)
        releaseHNSWIndexButton.addTarget(self, action: #selector(releaseHNSWIndexButtonTapped), for: .touchUpInside)
        releaseHNSWIndexButton.backgroundColor = .systemBlue
        releaseHNSWIndexButton.setTitleColor(.white, for: .normal)
        releaseHNSWIndexButton.layer.cornerRadius = 8
        
        hnswButtonsStackView2.addArrangedSubview(searchHNSWIndexButton)
        hnswButtonsStackView2.addArrangedSubview(clearHNSWIndexButton)
        hnswButtonsStackView2.addArrangedSubview(releaseHNSWIndexButton)
        
        contentView.addSubview(hnswButtonsStackView2)
        NSLayoutConstraint.activate([
            hnswButtonsStackView2.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            hnswButtonsStackView2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            hnswButtonsStackView2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            hnswButtonsStackView2.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        currentY += 40
        
        // HNSWIndex info
        hnswIndexInfoLabel.numberOfLines = 0
        hnswIndexInfoLabel.font = UIFont.systemFont(ofSize: 14)
        hnswIndexInfoLabel.text = "HNSWIndex ID: None\nVector count: 0"
        hnswIndexInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(hnswIndexInfoLabel)
        NSLayoutConstraint.activate([
            hnswIndexInfoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            hnswIndexInfoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding)
        ])
        
        currentY += 50
        
        // HNSWIndex results table
        hnswIndexResultsTableView.dataSource = self
        hnswIndexResultsTableView.delegate = self
        hnswIndexResultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ResultCell")
        hnswIndexResultsTableView.translatesAutoresizingMaskIntoConstraints = false
        hnswIndexResultsTableView.isHidden = true
        
        contentView.addSubview(hnswIndexResultsTableView)
        NSLayoutConstraint.activate([
            hnswIndexResultsTableView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            hnswIndexResultsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            hnswIndexResultsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            hnswIndexResultsTableView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        currentY += 220
        
        // MMapVectorStore section
        let mmapVectorStoreLabel = createSectionLabel(title: "MMapVectorStore (Memory-Mapped Vector Store)")
        contentView.addSubview(mmapVectorStoreLabel)
        NSLayoutConstraint.activate([
            mmapVectorStoreLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            mmapVectorStoreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding)
        ])
        
        currentY += 20
        
        // MMapVectorStore file path text field
        mmapFilePathTextField.placeholder = "Enter file path"
        mmapFilePathTextField.text = mmapFilePath
        mmapFilePathTextField.borderStyle = .roundedRect
        mmapFilePathTextField.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(mmapFilePathTextField)
        NSLayoutConstraint.activate([
            mmapFilePathTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            mmapFilePathTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            mmapFilePathTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            mmapFilePathTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        currentY += 50
        
        // MMapVectorStore buttons row
        let mmapVectorStoreButtonsStackView = UIStackView()
        mmapVectorStoreButtonsStackView.axis = .horizontal
        mmapVectorStoreButtonsStackView.distribution = .fillEqually
        mmapVectorStoreButtonsStackView.spacing = 8
        mmapVectorStoreButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        openMMapVectorStoreButton.setTitle("Open MMapVectorStore", for: .normal)
        openMMapVectorStoreButton.addTarget(self, action: #selector(openMMapVectorStoreButtonTapped), for: .touchUpInside)
        openMMapVectorStoreButton.backgroundColor = .systemBlue
        openMMapVectorStoreButton.setTitleColor(.white, for: .normal)
        openMMapVectorStoreButton.layer.cornerRadius = 8
        
        searchMMapVectorStoreButton.setTitle("Search", for: .normal)
        searchMMapVectorStoreButton.addTarget(self, action: #selector(searchMMapVectorStoreButtonTapped), for: .touchUpInside)
        searchMMapVectorStoreButton.backgroundColor = .systemBlue
        searchMMapVectorStoreButton.setTitleColor(.white, for: .normal)
        searchMMapVectorStoreButton.layer.cornerRadius = 8
        
        releaseMMapVectorStoreButton.setTitle("Release", for: .normal)
        releaseMMapVectorStoreButton.addTarget(self, action: #selector(releaseMMapVectorStoreButtonTapped), for: .touchUpInside)
        releaseMMapVectorStoreButton.backgroundColor = .systemBlue
        releaseMMapVectorStoreButton.setTitleColor(.white, for: .normal)
        releaseMMapVectorStoreButton.layer.cornerRadius = 8
        
        mmapVectorStoreButtonsStackView.addArrangedSubview(openMMapVectorStoreButton)
        mmapVectorStoreButtonsStackView.addArrangedSubview(searchMMapVectorStoreButton)
        mmapVectorStoreButtonsStackView.addArrangedSubview(releaseMMapVectorStoreButton)
        
        contentView.addSubview(mmapVectorStoreButtonsStackView)
        NSLayoutConstraint.activate([
            mmapVectorStoreButtonsStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            mmapVectorStoreButtonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            mmapVectorStoreButtonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            mmapVectorStoreButtonsStackView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        currentY += 50
        
        // MMapVectorStore info
        mmapVectorStoreInfoLabel.numberOfLines = 0
        mmapVectorStoreInfoLabel.font = UIFont.systemFont(ofSize: 14)
        mmapVectorStoreInfoLabel.text = "MMapVectorStore Status: None\nVector count: 0\nDimension: 0\nMetric:"
        mmapVectorStoreInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(mmapVectorStoreInfoLabel)
        NSLayoutConstraint.activate([
            mmapVectorStoreInfoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            mmapVectorStoreInfoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding)
        ])
        
        currentY += 80
        
        // MMapVectorStore results table
        mmapVectorStoreResultsTableView.dataSource = self
        mmapVectorStoreResultsTableView.delegate = self
        mmapVectorStoreResultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ResultCell")
        mmapVectorStoreResultsTableView.translatesAutoresizingMaskIntoConstraints = false
        mmapVectorStoreResultsTableView.isHidden = true
        
        contentView.addSubview(mmapVectorStoreResultsTableView)
        NSLayoutConstraint.activate([
            mmapVectorStoreResultsTableView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
            mmapVectorStoreResultsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            mmapVectorStoreResultsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            mmapVectorStoreResultsTableView.heightAnchor.constraint(equalToConstant: 200),
            mmapVectorStoreResultsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -horizontalPadding)
        ])
    }
    
    // MARK: - UI Helper Methods
    private func createSectionLabel(title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func updateStatus(message: String) {
        statusLabel.text = message
        statusLabel.sizeToFit()
    }
    
    private func createRandomVector(dimension: Int) -> [Double] {
        return (0..<dimension).map { _ in Double.random(in: -1...1) }
    }
    
    private func updateVectorStoreInfo() {
        let storeStatusText = vectorStore != nil ? "Created" : "None"
        vectorStoreInfoLabel.text = "VectorStore Status: \(storeStatusText)\nVector count: \(vectorStoreCount)"
    }
    
    private func updateHNSWIndexInfo() {
        let indexStatusText = hnswIndex != nil ? "Created" : "None"
        hnswIndexInfoLabel.text = "HNSWIndex Status: \(indexStatusText)\nVector count: \(hnswIndexCount)"
    }
    
    private func updateMMapVectorStoreInfo() {
        let storeStatusText = mmapVectorStore != nil ? "Opened" : "None"
        mmapVectorStoreInfoLabel.text = "MMapVectorStore Status: \(storeStatusText)\nVector count: \(mmapVectorStoreCount)\nDimension: \(mmapVectorStoreDimension)\nMetric: \(mmapVectorStoreMetric)"
    }
    
    // MARK: - Action Methods
    @objc private func dimensionSliderChanged(_ slider: UISlider) {
        dimension = Int(slider.value)
        dimensionLabel.text = "Vector Dimension: \(dimension)"
    }
    
    @objc private func metricSegmentedControlChanged(_ segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            selectedMetric = .l2
        case 1:
            selectedMetric = .cosine
        case 2:
            selectedMetric = .dot
        default:
            selectedMetric = .l2
        }
    }
    
    @objc private func hnswMSliderChanged(_ slider: UISlider) {
        hnswM = Int(slider.value)
        hnswMLabel.text = "M (Connections per node): \(hnswM)"
    }
    
    @objc private func hnswEfConstructionSliderChanged(_ slider: UISlider) {
        hnswEfConstruction = Int(slider.value)
        hnswEfConstructionLabel.text = "efConstruction: \(hnswEfConstruction)"
    }
    
    @objc private func searchKSliderChanged(_ slider: UISlider) {
        searchK = Int(slider.value)
        searchKLabel.text = "Search k: \(searchK)"
    }
    
    @objc private func efSearchSliderChanged(_ slider: UISlider) {
        efSearch = Int(slider.value)
        efSearchLabel.text = "HNSW efSearch: \(efSearch)"
    }
    
    // VectorStore operations
    @objc private func createVectorStoreButtonTapped() {
        updateStatus(message: "Creating VectorStore...")
        
        let options = VectorStoreOptions(dimension: dimension, metric: selectedMetric)
        
        do {
            let vectorStoreInstance = try VectorStore(options: options)
            vectorStore = vectorStoreInstance
            vectorStoreCount = 0
            vectorStoreResults.removeAll()
            vectorStoreResultsTableView.reloadData()
            vectorStoreResultsTableView.isHidden = true
            updateVectorStoreInfo()
            updateStatus(message: "VectorStore created successfully")
        } catch {
            updateStatus(message: "Error creating VectorStore: \(error.localizedDescription)")
        }
    }
    
    @objc private func addVectorsToStoreButtonTapped() {
        guard let vectorStore = vectorStore else {
            updateStatus(message: "Please create a VectorStore first")
            return
        }
        
        updateStatus(message: "Adding 100 vectors to VectorStore...")
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                for i in 0..<100 {
                    let vector = self.createRandomVector(dimension: self.dimension)
                    try vectorStore.addVector(vector: vector, vectorId: i + 1)
                }
                
                let count = try vectorStore.count()
                
                DispatchQueue.main.async {
                    self.vectorStoreCount = count
                    self.updateVectorStoreInfo()
                    self.updateStatus(message: "Added 100 vectors to VectorStore")
                }
            } catch {
                DispatchQueue.main.async {
                    self.updateStatus(message: "Error adding vectors to VectorStore: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func searchVectorStoreButtonTapped() {
        guard let vectorStore = vectorStore else {
            updateStatus(message: "Please create a VectorStore first")
            return
        }
        
        if vectorStoreCount == 0 {
            updateStatus(message: "Please add vectors to the VectorStore first")
            return
        }
        
        updateStatus(message: "Searching VectorStore...")
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let queryVector = self.createRandomVector(dimension: self.dimension)
                let results = try vectorStore.search(queryVector: queryVector, k: self.searchK)
                
                DispatchQueue.main.async {
                    self.vectorStoreResults = results
                    self.vectorStoreResultsTableView.reloadData()
                    self.vectorStoreResultsTableView.isHidden = false
                    self.updateStatus(message: "Search completed successfully")
                }
            } catch {
                DispatchQueue.main.async {
                    self.updateStatus(message: "Error searching VectorStore: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func clearVectorStoreButtonTapped() {
        guard let vectorStore = vectorStore else {
            updateStatus(message: "Please create a VectorStore first")
            return
        }
        
        updateStatus(message: "Clearing VectorStore...")
        
        do {
            try vectorStore.clear()
            
            vectorStoreCount = 0
            vectorStoreResults.removeAll()
            vectorStoreResultsTableView.reloadData()
            vectorStoreResultsTableView.isHidden = true
            updateVectorStoreInfo()
            updateStatus(message: "VectorStore cleared successfully")
        } catch {
            updateStatus(message: "Error clearing VectorStore: \(error.localizedDescription)")
        }
    }
    
    @objc private func releaseVectorStoreButtonTapped() {
        guard let vectorStore = vectorStore else {
            updateStatus(message: "Please create a VectorStore first")
            return
        }
        
        updateStatus(message: "Releasing VectorStore...")
        
        do {
            try vectorStore.release()
            
            self.vectorStore = nil
            vectorStoreCount = 0
            vectorStoreResults.removeAll()
            vectorStoreResultsTableView.reloadData()
            vectorStoreResultsTableView.isHidden = true
            updateVectorStoreInfo()
            updateStatus(message: "VectorStore released successfully")
        } catch {
            updateStatus(message: "Error releasing VectorStore: \(error.localizedDescription)")
        }
    }
    
    // HNSWIndex operations
    @objc private func createHNSWIndexButtonTapped() {
        updateStatus(message: "Creating HNSWIndex...")
        
        let options = HNSWIndexOptions(
            dimension: dimension,
            metric: selectedMetric,
            m: hnswM,
            efConstruction: hnswEfConstruction
        )
        
        do {
            let hnswIndexInstance = try HNSWIndex(options: options)
            hnswIndex = hnswIndexInstance
            hnswIndexCount = 0
            hnswIndexResults.removeAll()
            hnswIndexResultsTableView.reloadData()
            hnswIndexResultsTableView.isHidden = true
            updateHNSWIndexInfo()
            updateStatus(message: "HNSWIndex created successfully")
        } catch {
            updateStatus(message: "Error creating HNSWIndex: \(error.localizedDescription)")
        }
    }
    
    @objc private func addVectorsToHNSWButtonTapped() {
        guard let hnswIndex = hnswIndex else {
            updateStatus(message: "Please create a HNSWIndex first")
            return
        }
        
        updateStatus(message: "Adding 100 vectors to HNSWIndex...")
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                for i in 0..<100 {
                    let vector = self.createRandomVector(dimension: self.dimension)
                    try hnswIndex.addVector(vector: vector, vectorId: i + 1)
                }
                
                let count = try hnswIndex.count()
                
                DispatchQueue.main.async {
                    self.hnswIndexCount = count
                    self.updateHNSWIndexInfo()
                    self.updateStatus(message: "Added 100 vectors to HNSWIndex")
                }
            } catch {
                DispatchQueue.main.async {
                    self.updateStatus(message: "Error adding vectors to HNSWIndex: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func searchHNSWIndexButtonTapped() {
        guard let hnswIndex = hnswIndex else {
            updateStatus(message: "Please create a HNSWIndex first")
            return
        }
        
        if hnswIndexCount == 0 {
            updateStatus(message: "Please add vectors to the HNSWIndex first")
            return
        }
        
        updateStatus(message: "Searching HNSWIndex...")
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let queryVector = self.createRandomVector(dimension: self.dimension)
                let results = try hnswIndex.search(queryVector: queryVector, k: self.searchK, efSearch: self.efSearch)
                
                DispatchQueue.main.async {
                    self.hnswIndexResults = results
                    self.hnswIndexResultsTableView.reloadData()
                    self.hnswIndexResultsTableView.isHidden = false
                    self.updateStatus(message: "Search completed successfully")
                }
            } catch {
                DispatchQueue.main.async {
                    self.updateStatus(message: "Error searching HNSWIndex: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func clearHNSWIndexButtonTapped() {
        guard let hnswIndex = hnswIndex else {
            updateStatus(message: "Please create a HNSWIndex first")
            return
        }
        
        updateStatus(message: "Clearing HNSWIndex...")
        
        do {
            try hnswIndex.clear()
            
            hnswIndexCount = 0
            hnswIndexResults.removeAll()
            hnswIndexResultsTableView.reloadData()
            hnswIndexResultsTableView.isHidden = true
            updateHNSWIndexInfo()
            updateStatus(message: "HNSWIndex cleared successfully")
        } catch {
            updateStatus(message: "Error clearing HNSWIndex: \(error.localizedDescription)")
        }
    }
    
    @objc private func releaseHNSWIndexButtonTapped() {
        guard let hnswIndex = hnswIndex else {
            updateStatus(message: "Please create a HNSWIndex first")
            return
        }
        
        updateStatus(message: "Releasing HNSWIndex...")
        
        do {
            try hnswIndex.release()
            
            self.hnswIndex = nil
            hnswIndexCount = 0
            hnswIndexResults.removeAll()
            hnswIndexResultsTableView.reloadData()
            hnswIndexResultsTableView.isHidden = true
            updateHNSWIndexInfo()
            updateStatus(message: "HNSWIndex released successfully")
        } catch {
            updateStatus(message: "Error releasing HNSWIndex: \(error.localizedDescription)")
        }
    }
    
    // MARK: - MMapVectorStore Action Methods
    @objc private func openMMapVectorStoreButtonTapped() {
        // Update file path from text field
        if let text = mmapFilePathTextField.text, !text.isEmpty {
            mmapFilePath = text
        }
        
        updateStatus(message: "Opening MMapVectorStore from \(mmapFilePath)...")
        
        // Release existing store if any
        if let existingStore = mmapVectorStore {
            do {
                try existingStore.release()
            } catch {
                updateStatus(message: "Error releasing existing MMapVectorStore: \(error.localizedDescription)")
                return
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let mmapStore = try MMapVectorStore.open(filePath: self.mmapFilePath)
                let count = try mmapStore.count()
                let dimension = try mmapStore.dimension()
                let metric = try mmapStore.metric()
                
                DispatchQueue.main.async {
                    self.mmapVectorStore = mmapStore
                    self.mmapVectorStoreCount = count
                    self.mmapVectorStoreDimension = dimension
                    self.mmapVectorStoreMetric = metric.rawValue
                    self.mmapVectorStoreResults.removeAll()
                    self.mmapVectorStoreResultsTableView.reloadData()
                    self.mmapVectorStoreResultsTableView.isHidden = true
                    self.updateMMapVectorStoreInfo()
                    self.updateStatus(message: "MMapVectorStore opened successfully")
                }
            } catch {
                DispatchQueue.main.async {
                    self.updateStatus(message: "Error opening MMapVectorStore: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func searchMMapVectorStoreButtonTapped() {
        guard let mmapStore = mmapVectorStore else {
            updateStatus(message: "Please open a MMapVectorStore first")
            return
        }
        
        updateStatus(message: "Searching MMapVectorStore...")
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let queryVector = self.createRandomVector(dimension: self.mmapVectorStoreDimension)
                let results = try mmapStore.search(queryVector: queryVector, k: self.searchK)
                
                DispatchQueue.main.async {
                    self.mmapVectorStoreResults = results
                    self.mmapVectorStoreResultsTableView.reloadData()
                    self.mmapVectorStoreResultsTableView.isHidden = false
                    self.updateStatus(message: "Search completed successfully")
                }
            } catch {
                DispatchQueue.main.async {
                    self.updateStatus(message: "Error searching MMapVectorStore: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func releaseMMapVectorStoreButtonTapped() {
        guard let mmapStore = mmapVectorStore else {
            updateStatus(message: "Please open a MMapVectorStore first")
            return
        }
        
        updateStatus(message: "Releasing MMapVectorStore...")
        
        do {
            try mmapStore.release()
            
            self.mmapVectorStore = nil
            self.mmapVectorStoreCount = 0
            self.mmapVectorStoreDimension = 0
            self.mmapVectorStoreMetric = ""
            self.mmapVectorStoreResults.removeAll()
            self.mmapVectorStoreResultsTableView.reloadData()
            self.mmapVectorStoreResultsTableView.isHidden = true
            self.updateMMapVectorStoreInfo()
            self.updateStatus(message: "MMapVectorStore released successfully")
        } catch {
            updateStatus(message: "Error releasing MMapVectorStore: \(error.localizedDescription)")
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == vectorStoreResultsTableView {
            return vectorStoreResults.count
        } else if tableView == hnswIndexResultsTableView {
            return hnswIndexResults.count
        } else {
            return mmapVectorStoreResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath)
        
        let results: [SearchResult]
        if tableView == vectorStoreResultsTableView {
            results = vectorStoreResults
        } else if tableView == hnswIndexResultsTableView {
            results = hnswIndexResults
        } else {
            results = mmapVectorStoreResults
        }
        
        let result = results[indexPath.row]
        
        cell.textLabel?.text = "Vector \(result.index)"
        cell.detailTextLabel?.text = "Distance: \(String(format: "%.6f", result.distance))"
        cell.detailTextLabel?.textColor = .gray
        
        return cell
    }
}
