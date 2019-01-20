//
//  ViewController.swift
//  CalendarTest
//
//  Created by Greg Hughes on 1/19/19.
//  Copyright © 2019 Greg Hughes. All rights reserved.
//

import UIKit
import JTAppleCalendar
class ViewController: UIViewController {
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var month: UILabel!
    
    let outsideMonthColor = UIColor(colorWithHexValue: 0x584a66)
    let monthColor = UIColor.white
    let selectedMonthColor = UIColor(colorWithHexValue: 0x3a294b)
    let currentDateSelectedViewColor = UIColor(colorWithHexValue: 0x4e3f5d)
    
    
    var eventsFromServer: [String:String] = [:]
    let todayDate = Date()
    
    let formatter = DateFormatter()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //happens 2 sec after viewdidload for testing.
        //TODO: make this DispatchQueue.main.async
        //converting from json
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            
            let serverObjects = self.getServerEvents()
            
            for (date,event) in serverObjects{
                let stringDate = self.formatter.string(from: date)
                self.eventsFromServer[stringDate] = event
            }
            DispatchQueue.main.async {
                self.calendarView.reloadData()
            }
            
        }
        
        setupCalendarView()
        
        calendarView.scrollToDate(Date())
        //open with todays date
        calendarView.selectDates([Date()])
        
        
    }
    //loads current date on viewDidLoad
    func setupCalendarView(){
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        // MARK: - makes the spacing between days 0
        
        calendarView.visibleDates { (visibleDates) in
            self.setUpViewsOfCalendar(from: visibleDates)
        }
        
        
    }
    
    func getServerEvents()->[Date:String]{
        
        formatter.dateFormat = "yyyy MM dd"
        
        return[
            formatter.date(from: "2019 02 02")!: "Hello",
            formatter.date(from: "2019 02 05")!: "Hello",
            formatter.date(from: "2019 02 04")!: "Hello",
            formatter.date(from: "2019 02 03")!: "Hello"
        ]
    }
    
    
    
    
    
    // MARK: - Calendar vv handles colors for all text
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState){
        
        guard let validCell = view as? CustomCell else { return }
        
        if cellState.isSelected{
            validCell.dateLabel.textColor = selectedMonthColor
                //sets color of text for selected days
        } else {
            if cellState.dateBelongsTo == .thisMonth{
                //set color for cells of this month
                validCell.dateLabel.textColor = monthColor
            }else {
                validCell.dateLabel.textColor = outsideMonthColor
                //sets colors outside this month but still in view
            }
        }
        
    }
    // MARK: - Calendar vv toggles the color change in selected cells
    func handleCellSelected(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CustomCell else { return }
        if cellState.isSelected {
            validCell.selectedView.isHidden = false
        } else {
            validCell.selectedView.isHidden = true
        }
       
    }
    
    func setUpViewsOfCalendar(from visibleDates: DateSegmentInfo){
        let date = visibleDates.monthDates.first!.date
        
        self.formatter.dateFormat = "yyyy"
        self.year.text = self.formatter.string(from: date)
        
        self.formatter.dateFormat = "MMMM"
        self.month.text = self.formatter.string(from: date)
        //SETS THE MONTH TEXT WHEN SWIPED
    }
    
    func handleCellEvents(cell: CustomCell?, cellState: CellState){
        cell?.dot.isHidden = !eventsFromServer.contains {$0.key == formatter.string(from: cellState.date)}
        // MARK: - Calander Dot activates if we get info from server
    }
    
    func configureCell(cell: JTAppleCell?, cellState: CellState){
        
        guard let cell = cell as? CustomCell else { return }
        
        formatter.dateFormat = "yyy MM dd"
        
        handleCellEvents(cell: cell, cellState: cellState)
        
    }
   
    
}
extension ViewController: JTAppleCalendarViewDelegate{
    
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        
        cell.dateLabel.text = cellState.text
        
        handleCellTextColor(view: cell, cellState: cellState)
        // MARK: - Calendar resets cells when moving between months
        handleCellSelected(view:  cell, cellState: cellState)
        
        
        return cell
    }
    
    // MARK: - Calendar color change when selecting and de-selecting
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        handleCellSelected(view:  cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        
    }
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        handleCellSelected(view:  cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setUpViewsOfCalendar(from: visibleDates)
        
    }
}


extension ViewController: JTAppleCalendarViewDataSource{
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = cell as! CustomCell
        
        cell.dateLabel.text = cellState.text
    }
    
    
    // MARK: - Configuring Dates
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2017 02 01")
        let endDate = formatter.date(from: "2019 12 31")
        
        guard let sDate = startDate, let eDate = endDate else { return ConfigurationParameters(startDate: Date(), endDate: Date()) }
        // MARK: - showing buggy Date
        
        let parameters = ConfigurationParameters(startDate: sDate, endDate: eDate)
        return parameters
        
        }
}









extension UIColor{
    convenience init(colorWithHexValue value: Int, alpha: CGFloat = 1.0){
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x000FF) / 255.0,
            alpha: alpha
            // MARK: - Calendar allows us to use hex values...?
        )
    }
}
