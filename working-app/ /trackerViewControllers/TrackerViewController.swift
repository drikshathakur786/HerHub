import UIKit

class TrackerViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var checkInContainerView: UIView!
    @IBOutlet weak var forecastContainerView: UIView!
    @IBOutlet weak var todayInsightContainerView: UIView!
    
    @IBOutlet weak var insightTitleLabel: UILabel!
    @IBOutlet weak var insightDescriptionLabel: UILabel!
    
    @IBOutlet weak var moodValueLabel: UILabel!
    
    @IBOutlet weak var cycleDayValueLabel: UILabel!
    @IBOutlet weak var nextPeriodValueLabel: UILabel!
    @IBOutlet weak var phaseSubtitleLabel: UILabel! // Subtitle under "Today's Check-in"
    
    @IBOutlet weak var energyValueLabel: UILabel!
    
    // Grid StackView (to hide when showing capacity)
    @IBOutlet weak var checkInGridStackView: UIStackView!
    
    // MARK: - Storyboard Outlets (Preferred)
    // Connect these in Storyboard to avoid programmatic layout!
    @IBOutlet weak var capacityRingView: CapacityRingView!
    @IBOutlet weak var midStackView: UIStackView!
    
    // Bio-Capacity Components (Programmatic Fallbacks)
    private var theoryLabel: UILabel!
    private var realityLabel: UILabel!
    private var penaltyBreakdownLabel: UILabel!
    
    // Bio-Capacity Reference UI Components
    private var horizontalDivider: UIView!
    private var verticalDivider: UIView! 
    private var theoryIconLabel: UILabel!
    private var theoryValueLabel: UILabel!
    private var realityStackView: UIStackView!
    private var cycleDayCardLabel: UILabel!
    private var cycleDaySubtitleLabel: UILabel!
    private var confidenceCardLabel: UILabel!
    private var confidenceSubtitleLabel: UILabel!
    
    private var isPeriodCurrentlyActive: Bool = false
    private var checkInBarItemRef: UIBarButtonItem?
    
    
    
    @IBOutlet var dayLabels: [UILabel]!
    @IBOutlet var dateLabels: [UILabel]!
    @IBOutlet var moodLabels: [UILabel]!
    @IBOutlet var fertilityBoxes: [UILabel]!
    private var isLoadingData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationTitle()
        loadData() // Fetch data
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Reload data every time the screen appears (e.g. returning from forecast details)
        // Small delay to avoid racing with onSave callback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.loadData()
        }
    }
    
    // MARK: - Guest Guard for Storyboard Segues (e.g. "View Details")
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if AuthManager.shared.currentUser?.isGuest == true || AuthManager.shared.currentUser == nil {
            showGuestLoginPrompt()
            return false
        }
        return true
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Modern background gradient (matching Profile screen exactly for cohesive "Wow UI")
        let bgGradientLayer = CAGradientLayer()
        bgGradientLayer.frame = view.bounds
        bgGradientLayer.colors = [
            UIColor(red: 1.0, green: 0.96, blue: 0.98, alpha: 1.0).cgColor,
            UIColor(red: 0.98, green: 0.89, blue: 0.95, alpha: 1.0).cgColor,
            UIColor(red: 0.95, green: 0.88, blue: 0.96, alpha: 1.0).cgColor
        ]
        bgGradientLayer.locations = [0.0, 0.5, 1.0]
        bgGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        bgGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(bgGradientLayer, at: 0)
        
        // Force storyboard backgrounds to clear so the gradient is visible
        view.backgroundColor = .clear
        
        if let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            scrollView.backgroundColor = .clear
            if let contentView = scrollView.subviews.first {
                contentView.backgroundColor = .clear
            }
        }
        
        // check-in container styling (Apple Ecosystem premium feel)
        if let container = checkInContainerView {
            container.backgroundColor = .white
            container.layer.cornerRadius = 20
            container.layer.cornerCurve = .continuous
            
            // Remove any existing blur views if present
            container.subviews.filter { $0 is UIVisualEffectView }.forEach { $0.removeFromSuperview() }
            
            // Soft tinted shadow
            container.layer.shadowColor = UIColor(red: 0.4, green: 0.1, blue: 0.2, alpha: 1.0).cgColor
            container.layer.shadowOpacity = 0.08
            container.layer.shadowOffset = CGSize(width: 0, height: 8)
            container.layer.shadowRadius = 15
            
            // Performance rasterization
            container.layer.shouldRasterize = true
            container.layer.rasterizationScale = traitCollection.displayScale
        }
        
        // IMPORTANT: Hide check-in grid IMMEDIATELY to prevent overlap with capacity ring
        // The grid shows storyboard placeholder "Label" text and overlaps the Bio-Capacity UI
        checkInGridStackView?.isHidden = true
        
        // Set meaningful defaults for storyboard labels (replace "Label" placeholders)
        moodValueLabel?.text = "--"
        cycleDayValueLabel?.text = "--"
        nextPeriodValueLabel?.text = "--"
        energyValueLabel?.text = "--"
        phaseSubtitleLabel?.text = "Follicular Phase"
        insightTitleLabel?.text = "Welcome to HerHub"
        insightDescriptionLabel?.text = "Log your first check-in to see personalised cycle insights and predictions."
        
        // Info Button - Plain native iOS bar button
        let infoIcon = UIImage(systemName: "info.circle")
        let infoBarItem = UIBarButtonItem(image: infoIcon, style: .plain, target: self, action: #selector(presentCyclePhasesInfo))
        infoBarItem.tintColor = UIColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 1)
        
        // Check-in Button (+) - Plain native iOS bar button
        let checkInIcon = UIImage(systemName: "plus.circle.fill")
        let checkInBarItem = UIBarButtonItem(image: checkInIcon, style: .plain, target: self, action: #selector(presentDailyCheckIn))
        checkInBarItem.tintColor = UIColor(red: 0.9, green: 0.4, blue: 0.5, alpha: 1)
        
        // Store a reference to update it later
        self.checkInBarItemRef = checkInBarItem
        
        // Right bar: check-in first (rightmost), then info (left of it)
        // Note: the array is ordered right-to-left visually
        navigationItem.rightBarButtonItems = [checkInBarItem, infoBarItem]
        
        // Auto-Popup Check logic (Premium feature)
        checkCheckInStatus()
        
        // Auto-shrink fonts for value labels to prevent clipping
        [moodValueLabel, cycleDayValueLabel, nextPeriodValueLabel, energyValueLabel].forEach { label in
            label?.adjustsFontSizeToFitWidth = true
            label?.minimumScaleFactor = 0.7
            label?.numberOfLines = 1
        }
        
        // Setup Bio-Capacity Components
        
        setupBioCapacityComponents()
        setupMidSectionComponents()
        
        // Style the forecast card to look native iOS
        styleForecastCard()
    }
    
    
    
    private func setupBioCapacityComponents() {
        guard let container = checkInContainerView else { return }
        
        // 1. Capacity Ring: Check Outlet first
        if self.capacityRingView == nil {
            // Fallback: Create programmatically
            let ring = CapacityRingView(frame: CGRect(x: 0, y: 0, width: 140, height: 140))
            ring.translatesAutoresizingMaskIntoConstraints = false
            ring.showPercentage = true
            container.addSubview(ring)
            self.capacityRingView = ring
            
            // Constrain it only if we created it manually
             NSLayoutConstraint.activate([
                capacityRingView.topAnchor.constraint(equalTo: phaseSubtitleLabel.bottomAnchor, constant: 10),
                capacityRingView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                capacityRingView.widthAnchor.constraint(equalToConstant: 130),
                capacityRingView.heightAnchor.constraint(equalToConstant: 130)
            ])
            print("Technician Note: Please add a CapacityRingView to the storyboard and connect the outlet 'capacityRingView' to avoid programmatic layout.")
        }
        
        // 2. Horizontal Divider
        if horizontalDivider == nil {
            horizontalDivider = UIView()
            horizontalDivider.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            horizontalDivider.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(horizontalDivider)
        
             // 3. Vertical Divider
            verticalDivider = UIView()
            verticalDivider.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            verticalDivider.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(verticalDivider)
            
            NSLayoutConstraint.activate([
                 // Horizontal Divider
                horizontalDivider.topAnchor.constraint(equalTo: capacityRingView.bottomAnchor, constant: 15),
                horizontalDivider.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
                horizontalDivider.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
                horizontalDivider.heightAnchor.constraint(equalToConstant: 1),
                
                // Vertical Divider
                verticalDivider.topAnchor.constraint(equalTo: horizontalDivider.bottomAnchor, constant: 10),
                verticalDivider.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                verticalDivider.widthAnchor.constraint(equalToConstant: 1),
                verticalDivider.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -15)
            ])
             // Enforce min height
            let minHeight = verticalDivider.heightAnchor.constraint(greaterThanOrEqualToConstant: 65)
            minHeight.priority = .defaultHigh
            minHeight.isActive = true
        }
        
        
        // 4. Theory Section (Check if previously created or outlet exists - wait we don't have outlets for these yet)
        // Ideally we'd have outlets for all labels, but user asked for "Mid Stack" primarily.
        // We will stick to programmatic for the specific labels inside unless we want to add 10+ outlets.
        // For allow flexibility, we will check if the labels are already initialized (e.g. from storyboard via tag search? No, unsafe).
        // Safest: Use programmatic for labels if nil.
        
        if theoryLabel == nil {
            theoryLabel = UILabel()
            theoryLabel.text = "THEORY"
            theoryLabel.font = UIFont(name: "SFProRounded-Bold", size: 10) ?? .systemFont(ofSize: 10, weight: .bold)
            theoryLabel.textColor = .lightGray
            theoryLabel.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(theoryLabel)
            
            NSLayoutConstraint.activate([
                theoryLabel.topAnchor.constraint(equalTo: horizontalDivider.bottomAnchor, constant: 12),
                theoryLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20)
            ])
        }
        
        if theoryIconLabel == nil {
            theoryIconLabel = UILabel()
            theoryIconLabel.font = .systemFont(ofSize: 24)
            theoryIconLabel.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(theoryIconLabel)
             NSLayoutConstraint.activate([
                theoryIconLabel.topAnchor.constraint(equalTo: theoryLabel.bottomAnchor, constant: 8),
                theoryIconLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20)
             ])
        }
        
        // We need baselineText local var... but wait, the original code had it local.
        // We can just add it back.
        let baselineText = UILabel()
        baselineText.text = "Baseline"
        baselineText.font = UIFont(name: "SFProRounded-Medium", size: 12) ?? .systemFont(ofSize: 12, weight: .medium)
        baselineText.textColor = .darkGray
        baselineText.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(baselineText)
        
        if theoryValueLabel == nil {
            theoryValueLabel = UILabel()
            theoryValueLabel.text = "--%"
            theoryValueLabel.font = UIFont(name: "SFProRounded-Bold", size: 22) ?? .systemFont(ofSize: 22, weight: .bold)
            theoryValueLabel.textColor = .black
            theoryValueLabel.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(theoryValueLabel)
            
             NSLayoutConstraint.activate([
                 baselineText.topAnchor.constraint(equalTo: theoryLabel.bottomAnchor, constant: 10),
                 baselineText.leadingAnchor.constraint(equalTo: theoryIconLabel.trailingAnchor, constant: 8),
                 
                 theoryValueLabel.topAnchor.constraint(equalTo: baselineText.bottomAnchor, constant: 0),
                 theoryValueLabel.leadingAnchor.constraint(equalTo: theoryIconLabel.trailingAnchor, constant: 8),
             ])
        }
        
        // 5. Reality Section
        if realityLabel == nil {
            realityLabel = UILabel()
            realityLabel.text = "REALITY"
            realityLabel.font = UIFont(name: "SFProRounded-Bold", size: 10) ?? .systemFont(ofSize: 10, weight: .bold)
            realityLabel.textColor = .lightGray
            realityLabel.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(realityLabel)
            
             NSLayoutConstraint.activate([
                realityLabel.topAnchor.constraint(equalTo: horizontalDivider.bottomAnchor, constant: 12),
                realityLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20)
             ])
        }
        
        if realityStackView == nil {
            realityStackView = UIStackView()
            realityStackView.axis = .vertical
            realityStackView.spacing = 6
            realityStackView.alignment = .fill
            realityStackView.distribution = .fill
            realityStackView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(realityStackView)
            
            NSLayoutConstraint.activate([
                realityStackView.topAnchor.constraint(equalTo: realityLabel.bottomAnchor, constant: 8),
                realityStackView.leadingAnchor.constraint(equalTo: verticalDivider.trailingAnchor, constant: 15),
                realityStackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
                realityStackView.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -10)
            ])
        }
        
        // Penalty Breakdown for legacy support (hidden)
        if penaltyBreakdownLabel == nil {
            penaltyBreakdownLabel = UILabel()
            penaltyBreakdownLabel.isHidden = true
            container.addSubview(penaltyBreakdownLabel)
        }
        
        // Container Settings
        container.clipsToBounds = true
    }
    
    private func createRealityRow(title: String, value: String, color: UIColor = .systemRed) {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = UIFont(name: "SFProRounded-Medium", size: 12) ?? .systemFont(ofSize: 12, weight: .medium)
        titleLbl.textColor = .darkGray
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        
        let valLbl = UILabel()
        valLbl.text = value
        valLbl.font = UIFont(name: "SFProRounded-Bold", size: 12) ?? .systemFont(ofSize: 12, weight: .bold)
        valLbl.textColor = color
        valLbl.translatesAutoresizingMaskIntoConstraints = false
        
        row.addSubview(titleLbl)
        row.addSubview(valLbl)
        
        NSLayoutConstraint.activate([
            titleLbl.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            titleLbl.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            
            valLbl.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            valLbl.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            
            row.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        realityStackView.addArrangedSubview(row)
    }
    
    private func setupMidSectionComponents() {
        // 1. Check if connected via Outlet (Preferred)
        if let existingMidStack = self.midStackView {
            if existingMidStack.arrangedSubviews.isEmpty {
                 setupCardsInsideStack(existingMidStack)
            }
            return
        }
        
        // 2. Programmatic Layout
        guard let container = checkInContainerView, let superview = container.superview else { return }
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 15
        stack.translatesAutoresizingMaskIntoConstraints = false
        self.midStackView = stack
        
        setupCardsInsideStack(stack)
        
        // 3. Insert into parent stack view properly
        if let parentStack = superview as? UIStackView {
            // Parent is a UIStackView — insert as arranged subview right after the container
            if let containerIndex = parentStack.arrangedSubviews.firstIndex(of: container) {
                parentStack.insertArrangedSubview(stack, at: containerIndex + 1)
            } else {
                parentStack.addArrangedSubview(stack)
            }
            // Stack view handles spacing automatically, just set the height
            stack.heightAnchor.constraint(equalToConstant: 100).isActive = true
        } else {
            // Fallback: not in a stack view, use manual constraints
            superview.addSubview(stack)
            
            let forecast = forecastContainerView
            
            // Remove existing constraint between container and forecast
            let constraintsToDeactivate = superview.constraints.filter { constraint in
                return (constraint.firstItem as? UIView == container && constraint.secondItem as? UIView == forecast) ||
                       (constraint.firstItem as? UIView == forecast && constraint.secondItem as? UIView == container)
            }
            NSLayoutConstraint.deactivate(constraintsToDeactivate)
            
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: container.bottomAnchor, constant: 20),
                stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                stack.heightAnchor.constraint(equalToConstant: 100)
            ])
            
            if let forecast = forecast {
                forecast.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 20).isActive = true
            }
        }
    }

    private func setupCardsInsideStack(_ stack: UIStackView) {
        func createCard(title: String) -> (UIView, UILabel, UILabel) {
            let card = UIView()
            card.backgroundColor = .white
            card.layer.cornerRadius = 20
            card.layer.cornerCurve = .continuous
            
            // Soft tinted shadow (Apple ecosystem feel)
            card.layer.shadowColor = UIColor(red: 0.4, green: 0.1, blue: 0.2, alpha: 1.0).cgColor
            card.layer.shadowOpacity = 0.08
            card.layer.shadowOffset = CGSize(width: 0, height: 8)
            card.layer.shadowRadius = 15
            
            // Rasterization for 60fps scrolling
            card.layer.shouldRasterize = true
            card.layer.rasterizationScale = traitCollection.displayScale
            card.translatesAutoresizingMaskIntoConstraints = false
            
            let titleLabel = UILabel()
            titleLabel.text = title.uppercased()
            titleLabel.font = UIFont(name: "SFProRounded-Semibold", size: 12) ?? .systemFont(ofSize: 12, weight: .semibold)
            titleLabel.textColor = .lightGray
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(titleLabel)
            
            let valueLabel = UILabel()
            valueLabel.font = UIFont(name: "SFProRounded-Bold", size: 24) ?? .systemFont(ofSize: 24, weight: .bold)
            valueLabel.textColor = .black
            valueLabel.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(valueLabel)
            
            let subtitleLabel = UILabel()
            subtitleLabel.font = UIFont(name: "SFProRounded-Medium", size: 13) ?? .systemFont(ofSize: 13, weight: .medium)
            subtitleLabel.textColor = .rosePink
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(subtitleLabel)
            
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 15),
                titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
                
                valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
                valueLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
                
                subtitleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 5),
                subtitleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
                subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -15)
            ])
            
            return (card, valueLabel, subtitleLabel)
        }
        
        let (leftCard, cdLabel, cdSub) = createCard(title: "Cycle Day")
        cycleDayCardLabel = cdLabel
        cycleDaySubtitleLabel = cdSub
        stack.addArrangedSubview(leftCard)
        
        let (rightCard, confLabel, confSub) = createCard(title: "Next Period")
        confidenceCardLabel = confLabel
        confidenceSubtitleLabel = confSub
        stack.addArrangedSubview(rightCard)
    }
    
    // Helper to show/hide capacity dashboard
    private func showCapacityDashboard(_ show: Bool, animated: Bool = true) {
        let alpha: CGFloat = show ? 1.0 : 0.0
        let duration = animated ? 0.3 : 0.0
        
        UIView.animate(withDuration: duration) {
            self.capacityRingView.alpha = alpha
            self.theoryLabel.alpha = alpha
            self.realityLabel.alpha = alpha
            self.penaltyBreakdownLabel.alpha = alpha
        }
        
        // Hide the entire grid stackView when showing capacity (use isHidden to remove from layout)
        self.checkInGridStackView?.isHidden = show
    }
    
    
    
    private func setupNavigationTitle() {
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // Fully transparent nav bar — removes the pink blob behind the title
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "Tracker"
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = .black
        
        // Date subtitle
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        let subtitleLabel = UILabel()
        subtitleLabel.text = dateFormatter.string(from: Date())
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(stack)
        
        if let scrollView = self.view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            for constraint in self.view.constraints {
                if (constraint.firstItem as? UIView == scrollView && constraint.firstAttribute == .top) ||
                   (constraint.secondItem as? UIView == scrollView && constraint.secondAttribute == .top) {
                    constraint.isActive = false
                }
            }
            NSLayoutConstraint.activate([
                stack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
                stack.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 8),
                scrollView.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 4) // Reduced from 20 to 4
            ])
        }
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.titleView = nil
    }
    
    private func styleForecastCard() {
        guard let forecast = forecastContainerView else { return }
        
        // Clean white card with soft shadow
        forecast.backgroundColor = .white
        forecast.layer.cornerRadius = 20
        forecast.layer.cornerCurve = .continuous
        forecast.layer.shadowColor = UIColor(red: 0.4, green: 0.1, blue: 0.2, alpha: 1.0).cgColor
        forecast.layer.shadowOpacity = 0.08
        forecast.layer.shadowOffset = CGSize(width: 0, height: 8)
        forecast.layer.shadowRadius = 15
        forecast.layer.shouldRasterize = true
        forecast.layer.rasterizationScale = traitCollection.displayScale
        forecast.clipsToBounds = false
        
        // Clear backgrounds of ALL nested day-column wrapper views
        // These have systemBackgroundColor set in the storyboard which blocks the white card
        func clearNestedBackgrounds(_ view: UIView) {
            for subview in view.subviews {
                if !(subview is UILabel) && !(subview is UIButton) && !(subview is UIImageView) {
                    subview.backgroundColor = .clear
                }
                clearNestedBackgrounds(subview)
            }
        }
        clearNestedBackgrounds(forecast)
        
        // Style the day labels, date labels, and fertility boxes
        if let dayLabels = dayLabels {
            for label in dayLabels {
                label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
                label.textColor = .tertiaryLabel
            }
        }
        
        if let dateLabels = dateLabels {
            for label in dateLabels {
                label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
                label.textColor = .label
            }
        }
        
        if let fertilityBoxes = fertilityBoxes {
            for box in fertilityBoxes {
                box.layer.cornerRadius = 10
                box.layer.cornerCurve = .continuous
                box.layer.masksToBounds = true
                box.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
            }
        }
    }
    
    
    
    
    
    // Update gradient on layout changes (important!)
    // Update gradient and shadows on layout changes (important for performance!)
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update gradient frame if it exists
        if let gradientLayer = view.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
            if gradientLayer.frame != view.bounds {
                gradientLayer.frame = view.bounds
            }
        }
        
        // Update shadow paths for explicit containers
        if let container = checkInContainerView {
            container.layer.shadowPath = UIBezierPath(roundedRect: container.bounds, cornerRadius: container.layer.cornerRadius).cgPath
        }
        
        // Dynamically update shadow paths for programmatic mid-stack cards
        if let stack = midStackView {
            for card in stack.arrangedSubviews {
                card.layer.shadowPath = UIBezierPath(roundedRect: card.bounds, cornerRadius: card.layer.cornerRadius).cgPath
            }
        }
    }
    
    
    
    
    
    
    
    // MARK: - Check-In Logic
    
    @objc func presentDailyCheckIn() {
        // Guest guard — show "Create Account" popup
        if AuthManager.shared.currentUser?.isGuest == true || AuthManager.shared.currentUser == nil {
            showGuestLoginPrompt()
            return
        }
        
        let storyboard = UIStoryboard(name: "tracker", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "DailyCheckInViewController") as? DailyCheckInViewController else {
            print("Could not instantiate DailyCheckInViewController from storyboard")
            return
        }
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        // Pass logic to hide period switch if period is already active
        vc.hidePeriodSwitch = self.isPeriodCurrentlyActive
        
        // Refresh data after saving — delay slightly to ensure DB write is flushed
        vc.onSave = { [weak self] in
            print(" [Tracker] Check-in saved, reloading data...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.loadData()
            }
        }
        
        present(vc, animated: true)
    }
    
    @objc func presentCyclePhasesInfo() {
        let vc = CyclePhasesInfoViewController()
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        present(vc, animated: true)
    }
    

    func checkCheckInStatus() {
        Task {
            guard let currentUser = AuthManager.shared.currentUser else { return }
            
            // 1. Check if we already prompted TODAY (to avoid spamming on app restart)
            let defaults = UserDefaults.standard
            let todayKey = "lastCheckInPrompt_\(Date().formatted(date: .numeric, time: .omitted))"
            if defaults.bool(forKey: todayKey) { return }
            
            // 2. Check the LAST Check-In Date
            do {
                let checkIns = try await CycleDataController.shared.getCheckIns(forUser: currentUser.id)
                let lastCheckIn = checkIns.sorted(by: { $0.date > $1.date }).first
                
                let shouldPrompt: Bool
                if let lastDate = lastCheckIn?.date {
                    let daysSince = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
                    // Prompt if ~10 days have passed (approx 3 times a month)
                    shouldPrompt = daysSince >= 10
                } else {
                    // No history? Prompt to get baseline data
                    shouldPrompt = true
                }
                
                if shouldPrompt {
                    await MainActor.run {
                        // Mark as prompted for today so we don't ask again immediately
                        defaults.set(true, forKey: todayKey)
                        self.presentDailyCheckIn()
                    }
                }
                
            } catch {
                print("Error checking check-in status: \(error)")
            }
        }
    }

    // MARK: - Incomplete Baseline Alert
    
    private func showIncompleteBaselineAlert(dismissKey: String) {
        let alert = UIAlertController(
            title: "Complete Your Profile 📋",
            message: "Please fill in your height, weight, and past cycle history so we can generate more accurate predictions for you.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Complete Now", style: .default) { [weak self] _ in
            self?.presentBaselineOnboarding()
        })
        
        alert.addAction(UIAlertAction(title: "Later", style: .cancel) { _ in
            // Mark as dismissed so we only show once per session
            UserDefaults.standard.set(true, forKey: dismissKey)
        })
        
        present(alert, animated: true)
    }
    
    private func presentBaselineOnboarding() {
        let storyboard = UIStoryboard(name: "BaselineOnboarding", bundle: nil)
        if let onboardingVC = storyboard.instantiateInitialViewController() {
            onboardingVC.modalPresentationStyle = .fullScreen
            present(onboardingVC, animated: true) { [weak self] in
                // After completing the onboarding, reload data
                self?.loadData()
            }
        }
    }

    } 
    
    // MARK: - Load Cycle Data
    extension TrackerViewController {
        
        func loadData() {
            // Prevent concurrent loads from racing each other
            guard !isLoadingData else {
                print(" [Tracker] loadData skipped — already loading")
                return
            }
            isLoadingData = true
            
            Task {
                defer { Task { @MainActor in self.isLoadingData = false } }
                do {
                    guard let currentUser = AuthManager.shared.currentUser else {
                        print(" [Tracker] No user logged in — showing demo data")
                        await MainActor.run { self.populateGuestDummyData() }
                        return
                    }
                    
                    // Guest user — show demo data
                    if currentUser.isGuest {
                        await MainActor.run { self.populateGuestDummyData() }
                        return
                    }
                    
                    let userID = currentUser.id
                    
                    // 1. Fetch data
                    let checkIns = try await CycleDataController.shared.getCheckIns(forUser: userID)
                    let fetchedBaseline = try await CycleDataController.shared.getBaselineProfile(forUser: userID)
                    
                    // If no baseline exists for this logged-in user, create a default one
                    // so their check-in data still flows through the real tracker UI
                    var baseline: CycleBaselineProfile
                    if let existingBaseline = fetchedBaseline {
                        baseline = existingBaseline
                    } else {
                        print(" [Tracker] No baseline found — creating default for logged-in user")
                        baseline = CycleBaselineProfile.sample(userID: userID)
                        // Save it so it persists
                        try await CycleDataController.shared.saveBaselineProfile(baseline, forUser: userID)
                    }
                    
                    // Check if baseline profile is incomplete (user skipped questions)
                    // Only show popup if the key was explicitly set to false during onboarding
                    // (meaning user went through step 4 but left fields empty)
                    // If key doesn't exist at all, user completed onboarding before this feature — don't show
                    let completedKey = "baselineFullyCompleted_\(userID.uuidString)"
                    let completedValue = UserDefaults.standard.object(forKey: completedKey) as? Bool
                    
                    if completedValue == false {
                        let dismissedKey = "baselineIncompleteAlertDismissed_\(userID.uuidString)"
                        if !UserDefaults.standard.bool(forKey: dismissedKey) {
                            await MainActor.run {
                                self.showIncompleteBaselineAlert(
                                    dismissKey: dismissedKey
                                )
                            }
                        }
                    }
                    
                    // 2. Get Predicted Data
                    let prediction = PeriodPredictionService.shared.predict(baseline: baseline)
                    _ = prediction?.cycleLength ?? baseline.baseCycleLength
                    _ = prediction?.periodLength ?? baseline.basePeriodLength
                    let confidence = PeriodPredictionService.shared.calculateConfidence(baseline: baseline)
                    
                    // 3. Current Day & Phase (NO MODULO - Let reality drive the cycle)
                    let startOfLastPeriod = Calendar.current.startOfDay(for: baseline.lastPeriodStart)
                    let startOfToday = Calendar.current.startOfDay(for: Date())
                    let daysSinceLastPeriod = Calendar.current.dateComponents([.day], from: startOfLastPeriod, to: startOfToday).day ?? 0
                    let actualDay = daysSinceLastPeriod + 1
                    
                    // 4. Find check-in for TODAY
                    let today = Date()
                    let todayCheckIn = checkIns.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) })
                    
                    print(" [Tracker] Total check-ins: \(checkIns.count), Today's check-in found: \(todayCheckIn != nil)")
                    if let ci = todayCheckIn {
                        print(" [Tracker] Today's check-in → Sleep: \(ci.sleepHours)h, Stress: \(ci.currentStress)/10, Period: \(ci.periodStartedToday ?? false)")
                    }
                    
                    // 5. Update UI components
                    await MainActor.run {
                        updateMainTrackerUI(
                            actualDay: actualDay,
                            prediction: prediction,
                            baseline: baseline,
                            confidence: confidence,
                            todayCheckIn: todayCheckIn,
                            checkIns: checkIns
                        )
                    }
                    
                    // 6. Fetch upcoming 7-day forecasts
                    let upcomingForecasts = try await CycleDataController.shared.getUpcomingForecasts(forUser: userID)
                    updateForecastUI(upcomingForecasts)
                    
                } catch {
                    print("Error loading tracker data: \(error)")
                }
            }
        }
        
        @MainActor
        private func updateMainTrackerUI(actualDay: Int, prediction: (cycleLength: Int, periodLength: Int)?, baseline: CycleBaselineProfile, confidence: Double, todayCheckIn: CycleCheckIn?, checkIns: [CycleCheckIn]) {
            
            let cycleLength = prediction?.cycleLength ?? baseline.baseCycleLength
            let periodLength = prediction?.periodLength ?? baseline.basePeriodLength
            
            // RESET LOGIC: If period started today, override to Day 1
            var effectiveDay = actualDay
            if let checkIn = todayCheckIn, checkIn.periodStartedToday == true {
                effectiveDay = 1
            }
            
            let lateDays = PeriodPredictionService.shared.getLateDays(baseline: baseline, cycleLength: cycleLength)
            
            // Calculate phase (needed for both UI and capacity calculation)
            let phase = determinePhaseHeuristic(dayInCycle: effectiveDay, cycleLength: cycleLength, periodLength: periodLength)
            
            // Populate New Mid-Section Cards (Unconditional)
            // Calculate days to ovulation (approximate)
            let predictedOvulation = (prediction?.cycleLength ?? 28) / 2
            let daysToPeak = predictedOvulation - effectiveDay
            
            if effectiveDay > cycleLength && !(todayCheckIn?.periodStartedToday == true) {
                cycleDayCardLabel.text = "Late"
                cycleDaySubtitleLabel.text = "Day \(effectiveDay) of cycle"
                cycleDaySubtitleLabel.textColor = .systemRed
            } else {
                cycleDayCardLabel.text = "Day \(effectiveDay)"
                
                if daysToPeak > 0 {
                    cycleDaySubtitleLabel.text = "\(daysToPeak) days to peak"
                    cycleDaySubtitleLabel.textColor = .rosePink
                } else if daysToPeak == 0 {
                    cycleDaySubtitleLabel.text = "Peak day"
                    cycleDaySubtitleLabel.textColor = .rosePink
                } else {
                    cycleDaySubtitleLabel.text = "\(abs(daysToPeak)) days post peak"
                    cycleDaySubtitleLabel.textColor = .slateGray
                }
            }
            
            // NEXT PERIOD Logic (Replacing Confidence)
            let nextPeriodDate = PeriodPredictionService.shared.calculateNextPeriodDate(baseline: baseline)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d"
            
            confidenceCardLabel.text = dateFormatter.string(from: nextPeriodDate)
            
            let startOfNextPeriod = Calendar.current.startOfDay(for: nextPeriodDate)
            let startOfToday = Calendar.current.startOfDay(for: Date())
            let daysUntil = Calendar.current.dateComponents([.day], from: startOfToday, to: startOfNextPeriod).day ?? 0
            
            if daysUntil > 0 {
                confidenceSubtitleLabel.text = "in \(daysUntil) days"
                confidenceSubtitleLabel.textColor = .slateGray
            } else if daysUntil == 0 {
                confidenceSubtitleLabel.text = "Expected today"
                confidenceSubtitleLabel.textColor = .rosePink
            } else {
                confidenceSubtitleLabel.text = "Late \(abs(daysUntil)) days"
                confidenceSubtitleLabel.textColor = .systemRed
            }
            
            // 1. TOP CARD: Biological Ground Truth (Handle Late State)
            if effectiveDay > cycleLength && !(todayCheckIn?.periodStartedToday == true) {
                // LATE STATE: Don't restart the cycle artificially
                cycleDayValueLabel.text = "Day \(cycleLength)+: Late"
                phaseSubtitleLabel?.text = "Waiting for Cycle Reset"
            } else {
                // NORMAL STATE: Show actual phase
                cycleDayValueLabel.text = "Day \(effectiveDay): \(phase.rawValue.capitalized)"
                phaseSubtitleLabel?.text = "\(phase.rawValue.capitalized) Phase"
            }
            phaseSubtitleLabel?.textColor = .systemGray
            
            // 2. MIDDLE CARD: Prediction Confidence & Forecast
            let confidencePercent = Int(confidence * 100)
            let bottomNextPeriodDate = Calendar.current.date(byAdding: .day, value: cycleLength, to: baseline.lastPeriodStart)!
            let bottomDateFormatter = DateFormatter()
            bottomDateFormatter.dateFormat = "MMM d"
            
            if lateDays > 0 && !(todayCheckIn?.periodStartedToday == true) {
                nextPeriodValueLabel.text = "Late \(lateDays)d"
                nextPeriodValueLabel.textColor = .systemRed
                insightTitleLabel.text = "Why is it Late?"
                
                // Use the new analysis for actionable insights
                if let reason = PeriodPredictionService.shared.analyzeLatenessReasons(checkIns: checkIns, baseline: baseline) {
                    insightDescriptionLabel.text = reason
                } else {
                    insightDescriptionLabel.text = "Period hasn't started? Log it now to help the AI calibrate to your shift."
                }
            } else {
                nextPeriodValueLabel.text = "\(bottomDateFormatter.string(from: bottomNextPeriodDate)) (\(confidencePercent)%)"
                nextPeriodValueLabel.textColor = .darkGray
                
                // Default insights if no mismatch
                insightTitleLabel.text = "Prediction Confidence"
                insightDescriptionLabel.text = "Your cycle is following a \(confidencePercent)% regularity pattern based on your history."
            }
            
            // 3. BOTTOM: Bio-Capacity Dashboard (Always Visible)
            showCapacityDashboard(true)
            
            // 4. Update check-in button state
            self.isPeriodCurrentlyActive = effectiveDay <= periodLength
            if todayCheckIn != nil {
                self.checkInBarItemRef?.image = UIImage(systemName: "checkmark.circle.fill")
                self.checkInBarItemRef?.tintColor = .systemGreen
            } else {
                self.checkInBarItemRef?.image = UIImage(systemName: "plus.circle.fill")
                self.checkInBarItemRef?.tintColor = UIColor(red: 0.9, green: 0.4, blue: 0.5, alpha: 1)
            }
            
            // Calculate capacity (Check-in optional - handles nil gracefully)
            let capacity = PeriodPredictionService.shared.calculateBioCapacity(
                phase: effectiveDay > cycleLength ? .luteal : phase,
                checkIn: todayCheckIn,
                baseline: baseline
            )
            
            // Update capacity ring with spring animation
            capacityRingView.updateCapacity(capacity, animated: true)
            
            // Build Theory/Reality breakdown
            let hormonalBaseline: Int = {
                switch phase {
                case .menstrual: return 40
                case .follicular: return 85
                case .ovulation: return 95
                case .luteal: return 65
                }
            }()
            
            // Theory display (heading only, no emoji, no duplicate text)
            theoryLabel.text = "Baseline"
            theoryValueLabel.text = "\(hormonalBaseline)%"
            
            // Reality display
            realityStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            if let checkIn = todayCheckIn {
                // REALITY: Based on actual logs
                realityLabel.text = "REALITY"
                realityLabel.textColor = .black
                
                if checkIn.sleepHours < 7 {
                    let penalty = Int((7 - checkIn.sleepHours) * 5)
                    createRealityRow(title: "Sleep", value: "-\(penalty)%", color: .systemRed)
                } else {
                    createRealityRow(title: "Sleep", value: "Optimal", color: .systemGray)
                }
                
                if checkIn.currentStress > 5 {
                    let penalty = (checkIn.currentStress - 5) * 3
                    createRealityRow(title: "Stress", value: "-\(penalty)%", color: .systemRed)
                } else {
                    createRealityRow(title: "Stress", value: "Optimal", color: .systemGray)
                }
                
                if checkIn.exerciseChange != .same {
                     createRealityRow(title: "Exercise", value: "-10%", color: .systemRed)
                }
                
                if checkIn.sleepHours >= 7 && checkIn.currentStress <= 5 && checkIn.exerciseChange == .same {
                     createRealityRow(title: "Lifestyle", value: "Perfect ✓", color: UIColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 1))
                }

                // Update Stats
                moodValueLabel.text = checkIn.symptomsPresent ? "Mixed" : "Good"
                energyValueLabel.text = checkIn.sleepHours >= 7 ? "High" : "Low"
                
                // MISMATCH LOGIC (InsightEngine)
                let actualEnergy = checkIn.sleepHours >= 7 ? "High" : "Low"
                if let result = PeriodPredictionService.shared.getMismatchInsight(phase: phase, actualEnergy: actualEnergy, baseline: baseline) {
                    insightTitleLabel.text = "Hormonal Insight"
                    insightDescriptionLabel.text = result.insight
                }

            } else {
                // THEORETICAL: Estimation based on baseline
                realityLabel.text = "ESTIMATED"
                realityLabel.textColor = .systemGray
                
                var hasBaselinePenalty = false
                
                // Show potential penalties based on baseline profile
                if baseline.baselineStress > 5 {
                    let penalty = (baseline.baselineStress - 5) * 3
                    createRealityRow(title: "Stress (Base)", value: "-\(penalty)%", color: .systemOrange)
                    hasBaselinePenalty = true
                }
                
                if !hasBaselinePenalty {
                    createRealityRow(title: "Pending data...", value: "")
                }
                
                moodValueLabel.text = "--"
                energyValueLabel.text = "--"
                insightTitleLabel.text = "How do you feel?"
                insightDescriptionLabel.text = "Log your morning check-in to see how your body matches its hormonal expectations."
            }
        }
        
        private func determinePhaseHeuristic(dayInCycle: Int, cycleLength: Int, periodLength: Int) -> CyclePhase {
            if dayInCycle <= periodLength {
                return .menstrual
            }
            
            // LUTEAL-BACKWARDS CALCULATION: Ovulation is typically 14 days before next period
            let predictedOvulationDay = cycleLength - 14
            
            if dayInCycle < predictedOvulationDay - 2 {
                return .follicular
            } else if dayInCycle <= predictedOvulationDay + 2 {
                return .ovulation
            } else {
                return .luteal
            }
        }
        
        
        
        
        
        // MARK: - Update 7-Day Forecast Section (Using forecastContainerView)
        @MainActor
        private func updateForecastUI(_ items: [DailyForecast]) {
            
            guard items.count >= 7 else {
                print("updateForecastUI: Expected 7 forecasts, got \(items.count)")
                return
            }
            
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEE"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d"
            
            // Safety check: Make sure IBOutlets have exactly 7 labels
            // Note: Check if outlets are connected before accessing count to avoid crash if nil
            guard let dayLabels = dayLabels, dayLabels.count == 7,
                  let dateLabels = dateLabels, dateLabels.count == 7,
                  let moodLabels = moodLabels, moodLabels.count == 7,
                  let fertilityBoxes = fertilityBoxes, fertilityBoxes.count == 7 else {
                print("Forecast UI arrays are not connected or length != 7.")
                return
            }
            
            for i in 0..<7 {
                let forecast = items[i]
                
                // DAY LABEL
                dayLabels[i].text = dayFormatter.string(from: forecast.date)
                dayLabels[i].textColor = .systemGray
                dayLabels[i].font = UIFont.systemFont(ofSize: 12, weight: .medium)
                
                // DATE LABEL
                dateLabels[i].text = dateFormatter.string(from: forecast.date)
                dateLabels[i].font = UIFont.boldSystemFont(ofSize: 14)
                dateLabels[i].textColor = .black
                
                // MOOD LABEL (Removed per request)
                moodLabels[i].text = "" // Hiding mood text
                moodLabels[i].font = UIFont.systemFont(ofSize: 12)
                moodLabels[i].textColor = .systemGray2
                
                // FERTILITY BOX
                let box = fertilityBoxes[i]
                box.text = forecast.fertility.displayName
                box.textAlignment = .center
                box.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
                box.textColor = .white
                
                // Modern squircle pill
                box.layer.cornerRadius = 10
                box.layer.cornerCurve = .continuous
                box.layer.masksToBounds = true
                
                switch forecast.fertility {
                case .low:
                    box.backgroundColor = UIColor.systemRed.withAlphaComponent(0.12)
                    box.textColor = .systemRed
                case .med:
                    box.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
                    box.textColor = .systemOrange
                case .high:
                    box.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
                    box.textColor = .systemBlue
                }
            }
        }
        
        // MARK: - Guest / Demo Data
        @MainActor
        private func populateGuestDummyData() {
            // -- Top Card: Today's Check-in --
            phaseSubtitleLabel?.text = "Follicular Phase"
            phaseSubtitleLabel?.textColor = .systemGray
            cycleDayValueLabel?.text = "Day 8: Follicular"
            
            // -- Bio-Capacity Ring (85% for follicular) --
            showCapacityDashboard(true)
            capacityRingView?.updateCapacity(85, animated: true)
            
            // -- Theory / Reality sections --
            theoryLabel?.text = "Baseline"
            theoryValueLabel?.text = "85%"
            
            realityStackView?.arrangedSubviews.forEach { $0.removeFromSuperview() }
            realityLabel?.text = "ESTIMATED"
            realityLabel?.textColor = .systemGray
            createRealityRow(title: "Sleep", value: "Optimal", color: .systemGray)
            createRealityRow(title: "Stress", value: "Optimal", color: .systemGray)
            
            // -- Mid Cards: Cycle Day & Next Period --
            cycleDayCardLabel?.text = "Day 8"
            cycleDaySubtitleLabel?.text = "6 days to peak"
            cycleDaySubtitleLabel?.textColor = .rosePink
            
            let nextPeriodDate = Calendar.current.date(byAdding: .day, value: 20, to: Date()) ?? Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d"
            confidenceCardLabel?.text = dateFormatter.string(from: nextPeriodDate)
            confidenceSubtitleLabel?.text = "in 20 days"
            confidenceSubtitleLabel?.textColor = .slateGray
            
            // -- Bottom storyboard labels --
            moodValueLabel?.text = "Good"
            energyValueLabel?.text = "High"
            nextPeriodValueLabel?.text = dateFormatter.string(from: nextPeriodDate)
            
            // -- Insight Card --
            insightTitleLabel?.text = "Prediction Confidence"
            insightDescriptionLabel?.text = "Your cycle is following a 78% regularity pattern. Log daily check-ins to improve accuracy."
            
            // -- 7-Day Forecast (populate with sample data) --
            populateGuestForecast()
        }
        
        @MainActor
        private func populateGuestForecast() {
            guard let dayLabels = dayLabels, dayLabels.count == 7,
                  let dateLabels = dateLabels, dateLabels.count == 7,
                  let moodLabels = moodLabels, moodLabels.count == 7,
                  let fertilityBoxes = fertilityBoxes, fertilityBoxes.count == 7 else {
                return
            }
            
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEE"
            let dateFmt = DateFormatter()
            dateFmt.dateFormat = "d"
            
            // Sample fertility pattern for follicular phase
            let sampleFertility: [String] = ["Low", "Low", "Med", "Med", "High", "High", "Med"]
            let sampleColors: [UIColor] = [
                UIColor(red: 1, green: 0.35, blue: 0.47, alpha: 1),  // Low
                UIColor(red: 1, green: 0.35, blue: 0.47, alpha: 1),  // Low
                UIColor(red: 1, green: 0.80, blue: 0.25, alpha: 1),  // Med
                UIColor(red: 1, green: 0.80, blue: 0.25, alpha: 1),  // Med
                UIColor(red: 0.25, green: 0.51, blue: 1, alpha: 1),  // High
                UIColor(red: 0.25, green: 0.51, blue: 1, alpha: 1),  // High
                UIColor(red: 1, green: 0.80, blue: 0.25, alpha: 1),  // Med
            ]
            let sampleMoods = ["Good", "Great", "Okay", "Happy", "Happy", "Calm", "Tired"]
            
            for i in 0..<7 {
                let date = Calendar.current.date(byAdding: .day, value: i, to: Date()) ?? Date()
                
                dayLabels[i].text = dayFormatter.string(from: date)
                dayLabels[i].textColor = .systemGray
                dayLabels[i].font = UIFont.systemFont(ofSize: 12, weight: .medium)
                
                dateLabels[i].text = dateFmt.string(from: date)
                dateLabels[i].font = UIFont.boldSystemFont(ofSize: 14)
                dateLabels[i].textColor = .black
                
                moodLabels[i].text = sampleMoods[i]
                moodLabels[i].font = UIFont.systemFont(ofSize: 12)
                moodLabels[i].textColor = .systemGray2
                
                let box = fertilityBoxes[i]
                box.text = sampleFertility[i]
                box.textAlignment = .center
                box.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
                box.textColor = .white
                box.layer.cornerRadius = 6
                box.layer.masksToBounds = true
                box.backgroundColor = sampleColors[i]
            }
        }
    }
    
    extension DailyForecast {
        var phaseDescription: String {
            switch phase {
            case .follicular: return "Good"
            case .ovulation:  return "Happy"
            case .luteal:     return "Okay"
            case .menstrual:  return "Calm"
            }
        }
    }
    
    

