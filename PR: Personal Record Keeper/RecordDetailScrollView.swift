//
//  RecordDetailScrollView.swift
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 7/13/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit
import Charts

 class RecordDetailScrollView: UIScrollView {
    private let screenWidth = UIScreen.main.bounds.width
    private let VERTICAL_SPACING:CGFloat = 34.0
    
    var datesArray:[Date]?
    
    let row_activityInfo: RoundedRectView = {
        let rowView = RoundedRectView(size: (UIScreen.main.bounds.width - 16.0, 40.0), color: UIColor.PRColors.prBlue.withAlphaComponent(0.6))
        return rowView
    }()
    let row_basicInfo: RoundedRectView = {
        let rowView = RoundedRectView(size: (UIScreen.main.bounds.width - 16.0, nil), color: UIColor.white)
        return rowView
    }()
    let row_notes: RoundedRectView = { //May be hidden if no notes
        let rowView = RoundedRectView(size: (UIScreen.main.bounds.width - 16.0, nil), color: UIColor.white)
        return rowView
    }()
    let row_graph: RoundedRectView = {
        let rowView = RoundedRectView(size: (UIScreen.main.bounds.width - 16.0, 225), color: UIColor.white)
        return rowView
    }()
    let row_viewOld: RoundedRectView = {
        let rowView = RoundedRectView(size: (UIScreen.main.bounds.width - 16.0, 40), color: UIColor.white)
        rowView.shouldAnimate = true
        return rowView
    }()
    
    //Row 1
    let distanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 22.0)
        label.textColor = .white
        return label
    }()
    let typeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .right
        imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100))
        imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20))
        return imageView
    }()
    
    //Row 2
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18.0)
        label.textColor = .lightGray
        label.text = "Time"
        return label
    }()
    let timeValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 55.0)
        label.textColor = .darkGray
        return label
    }()
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18.0)
        label.textColor = .lightGray
        label.text = "Date"
        return label
    }()
    let dateValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20.0)
        label.textColor = UIColor.PRColors.prBlue
        return label
    }()
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18.0)
        label.textColor = .lightGray
        label.text = "Location"
        return label
    }()
    let locationValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20.0)
        label.textColor = UIColor.PRColors.prBlue
        return label
    }()
    
    // Row 3
    let notesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18.0)
        label.textColor = .lightGray
        label.text = "Notes"
        return label
    }()
    let notesValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18.0)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    // Row 4
    
    let lineChartView: LineChartView = {
        let chart = LineChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.chartDescription?.enabled = true
        chart.dragEnabled = true
        chart.setScaleEnabled(false)
        chart.maxVisibleCount = 5
        chart.pinchZoomEnabled = false
        chart.backgroundColor = .clear
        chart.legend.enabled = false
        
        chart.leftAxis.enabled = false
        chart.rightAxis.enabled = true
        chart.rightAxis.drawGridLinesEnabled = false
        chart.rightAxis.valueFormatter = TimeValueFormatter()
        chart.rightAxis.axisMinimum = 0.0
        
        chart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        chart.xAxis.drawLabelsEnabled = false
        chart.xAxis.drawGridLinesEnabled = false
        chart.xAxis.avoidFirstLastClippingEnabled = true
        
        let marker = BalloonMarker(color: UIColor(white: 180/255, alpha: 1),
                                   font: .systemFont(ofSize: 12),
                                   textColor: .white,
                                   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.color = UIColor(white: 0.9, alpha: 0.75)
        marker.textColor = .black
        marker.chartView = chart
        marker.minimumSize = CGSize(width: 80, height: 40)
        
        chart.marker = marker
        
        //date formatter should be provided by controller
        
        return chart
    }()
    
    // Row 5
    private let oldRecordsLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "View old records"
        label.textColor = UIColor.PRColors.prBlue
        return label
    }()
    
    
    // MARK: Interaction methods
    public func setTypeImage(type: RecordType){
        let image:UIImage = {
            switch type{
            case .run:
                return #imageLiteral(resourceName: "Type_run")
            case .swim:
                return #imageLiteral(resourceName: "Type_swim")
            case .triathlon:
                return #imageLiteral(resourceName: "Type_triathlon")
            case .none:
                return UIImage()
            }
        }()
        typeImageView.image = image.withRenderingMode(.alwaysTemplate)
        typeImageView.tintColor = .white
    }
    
    //MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createViews()
    }
    
    override open class var requiresConstraintBasedLayout: Bool{
        return true
    }
    
    private func createViews(){
        //set up views
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentSize.width = UIScreen.main.bounds.width
        
        self.addSubview(row_activityInfo)
        self.addSubview(row_basicInfo)
        self.addSubview(row_notes)
        self.addSubview(row_graph)
        self.addSubview(row_viewOld)
        
        layout_row_activityInfo()
        layout_row_basicInfo()
        layout_row_notes()
        layout_row_graph()
        layout_row_viewOld()
        
        //add subviews to each
        addSubviews_row_activityInfo()
        addSubviews_row_basicInfo()
        addSubviews_row_notes()
        addSubviews_row_graph()
        addSubviews_row_viewOld()
    }
    
    private func layout_row_activityInfo(){
        row_activityInfo.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8.0).isActive = true
        row_activityInfo.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 8.0).isActive = true
        row_activityInfo.topAnchor.constraint(equalTo: self.topAnchor, constant: 8.0).isActive = true
        row_activityInfo.bottomAnchor.constraint(equalTo: row_basicInfo.topAnchor, constant: -8.0).isActive = true
    }
    
    private func layout_row_basicInfo(){
        row_basicInfo.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8.0).isActive = true
        row_basicInfo.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 8.0).isActive = true
        row_basicInfo.bottomAnchor.constraint(equalTo: row_notes.topAnchor, constant: -8.0).isActive = true
    }
    
    private func layout_row_notes(){
        row_notes.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8.0).isActive = true
        row_notes.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 8.0).isActive = true
        row_notes.bottomAnchor.constraint(equalTo: row_graph.topAnchor, constant: -8.0).isActive = true
    }
    
    private func layout_row_graph(){
        row_graph.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8.0).isActive = true
        row_graph.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 8.0).isActive = true
        row_graph.bottomAnchor.constraint(equalTo: row_viewOld.topAnchor, constant: -8.0).isActive = true
    }
    
    private func layout_row_viewOld(){
        row_viewOld.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8.0).isActive = true
        row_viewOld.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 8.0).isActive = true
        row_viewOld.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8.0).isActive = true
    }
    
    private func addSubviews_row_activityInfo(){
        row_activityInfo.addSubview(distanceLabel)
        row_activityInfo.addSubview(typeImageView)
        distanceLabel.leadingAnchor.constraint(equalTo: row_activityInfo.leadingAnchor, constant: 12.0).isActive = true
        distanceLabel.centerYAnchor.constraint(equalTo: row_activityInfo.centerYAnchor).isActive = true

        typeImageView.trailingAnchor.constraint(equalTo: row_activityInfo.trailingAnchor, constant: -12.0).isActive = true
        typeImageView.centerYAnchor.constraint(equalTo: distanceLabel.centerYAnchor).isActive = true
    }
    
    private func addSubviews_row_basicInfo(){
        row_basicInfo.addSubview(timeValueLabel)
        row_basicInfo.addSubview(timeLabel)
        row_basicInfo.addSubview(dateValueLabel)
        row_basicInfo.addSubview(dateLabel)
        row_basicInfo.addSubview(locationValueLabel)
        row_basicInfo.addSubview(locationLabel)
        
        timeValueLabel.trailingAnchor.constraint(equalTo: row_basicInfo.trailingAnchor, constant: -12.0).isActive = true
        timeValueLabel.topAnchor.constraint(equalTo: row_basicInfo.topAnchor, constant: VERTICAL_SPACING).isActive = true
        timeLabel.leadingAnchor.constraint(equalTo: row_basicInfo.leadingAnchor, constant: 8.0).isActive = true
        timeLabel.lastBaselineAnchor.constraint(equalTo: timeValueLabel.lastBaselineAnchor).isActive = true
        
        dateValueLabel.trailingAnchor.constraint(equalTo: row_basicInfo.trailingAnchor, constant: -12.0).isActive = true
        dateValueLabel.topAnchor.constraint(equalTo: timeValueLabel.bottomAnchor, constant: VERTICAL_SPACING).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: row_basicInfo.leadingAnchor, constant: 8.0).isActive = true
        dateLabel.lastBaselineAnchor.constraint(equalTo: dateValueLabel.lastBaselineAnchor).isActive = true
        
        locationValueLabel.trailingAnchor.constraint(equalTo: row_basicInfo.trailingAnchor, constant: -12.0).isActive = true
        locationValueLabel.topAnchor.constraint(equalTo: dateValueLabel.bottomAnchor, constant: VERTICAL_SPACING).isActive = true
        locationLabel.leadingAnchor.constraint(equalTo: row_basicInfo.leadingAnchor, constant: 8.0).isActive = true
        locationLabel.lastBaselineAnchor.constraint(equalTo: locationValueLabel.lastBaselineAnchor).isActive = true
        locationValueLabel.bottomAnchor.constraint(equalTo: row_basicInfo.bottomAnchor, constant: -1 * VERTICAL_SPACING).isActive = true
    }
    
    private func addSubviews_row_notes(){
        row_notes.addSubview(notesLabel)
        row_notes.addSubview(notesValueLabel)
        
        notesLabel.topAnchor.constraint(equalTo: row_notes.topAnchor, constant: 12.0).isActive = true
        notesLabel.leadingAnchor.constraint(equalTo: row_notes.leadingAnchor, constant: 12.0).isActive = true
        
        notesValueLabel.topAnchor.constraint(equalTo: notesLabel.bottomAnchor, constant: 6.0).isActive = true
        notesValueLabel.leadingAnchor.constraint(equalTo: row_notes.leadingAnchor, constant: 12.0).isActive = true
        notesValueLabel.trailingAnchor.constraint(equalTo: row_notes.trailingAnchor, constant: -12.0).isActive = true
        notesValueLabel.bottomAnchor.constraint(equalTo: row_notes.bottomAnchor, constant: -12).isActive = true
        
    }
    
    private func addSubviews_row_graph(){
        row_graph.addSubview(lineChartView)
        
        lineChartView.trailingAnchor.constraint(equalTo: row_graph.trailingAnchor, constant: -4.0).isActive = true
        lineChartView.leadingAnchor.constraint(equalTo: row_graph.leadingAnchor, constant: 4.0).isActive = true
        lineChartView.topAnchor.constraint(equalTo: row_graph.topAnchor, constant: 8.0).isActive = true
        lineChartView.bottomAnchor.constraint(equalTo: row_graph.bottomAnchor, constant: -8.0).isActive = true
    }
    
    private func addSubviews_row_viewOld(){
        row_viewOld.addSubview(oldRecordsLabel)
        
        oldRecordsLabel.centerXAnchor.constraint(equalTo: row_viewOld.centerXAnchor).isActive = true
        oldRecordsLabel.centerYAnchor.constraint(equalTo: row_viewOld.centerYAnchor).isActive = true
    }
}
