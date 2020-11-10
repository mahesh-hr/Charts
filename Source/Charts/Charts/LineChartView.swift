//
//  LineChartView.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

public enum ChartType {
    case TMP
    case RN
    case WND
}

/// Chart that draws lines, surfaces, circles, ...
open class LineChartView: BarLineChartViewBase, LineChartDataProvider
{
    internal override func initialize()
    {
        super.initialize()
        
        renderer = LineChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: _viewPortHandler)
    }
    
    // MARK: - LineChartDataProvider
    
    open var lineData: LineChartData? { return _data as? LineChartData }
    public var type: ChartType = .TMP
}


extension LineChartView {
    
    private class LineChartValueFormatter: IValueFormatter {
        open var values: [String] = []
        open var secondaryValues: [String] = []
        
        func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
            return values[Int(entry.x)]
        }
        
        func secondaryStringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
            guard let secondValue = Float(secondaryValues[Int(entry.x)]), secondValue > 0 else {
                return ""
            }
            
            return secondaryValues[Int(entry.x)]
        }
    }
    
    class LineChartFormatter: NSObject, IAxisValueFormatter {
        
        var labels: [String] = []
        
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            if labels.count > Int(value) {
                return labels[Int(value)]
            } else {
                return ""
            }
        }
        
        init(labels: [String]) {
            super.init()
            self.labels = labels
        }
    }
    
    public func setHourlyLineChartData(xValues: [String],
                                       yValues: [Double],
                                       referenceLine1 : [Double],
                                       referenceLine2 : [Double],
                                       referenceLine3 : [Double],
                                       icons: [UIImage],
                                       rainValues :[Double]) {
        
        
        let color = NSUIColor(
            red: CGFloat(99) / 255.0,
            green: CGFloat(99) / 255.0,
            blue: CGFloat(99) / 255.0,
            alpha: CGFloat(1.0)
        )
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<yValues.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: yValues[i], icon: icons[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(entries: dataEntries, label: "")
        chartDataSet.drawIconsEnabled = true
        chartDataSet.lineDashLengths = [5.0, 0.0]
        chartDataSet.setDrawHighlightIndicators(false)
        chartDataSet.setColor(NSUIColor(red: 168/255.0, green: 127/255.0, blue: 127/255.0, alpha: 1))
        chartDataSet.lineWidth = 1.0;
        chartDataSet.valueFont = UIFont.init(name: "Barlow-Regular", size: 12.0)!
        chartDataSet.formLineWidth = 1.0
        chartDataSet.formSize = 15.0
        chartDataSet.mode = .horizontalBezier
        
        chartDataSet.drawCirclesEnabled = true
        chartDataSet.drawFilledEnabled = true
        chartDataSet.drawCircleHoleEnabled = false
        chartDataSet.circleHoleRadius = 0
        chartDataSet.circleRadius = 2
        chartDataSet.setCircleColor(color)
        chartDataSet.fillColor = NSUIColor.clear
        
        
        let maxRain = rainValues.max()
        var chartData = LineChartData()
        
        if maxRain != 0 {
            //****** RAIN Line ****** //
            var raindataEntries: [ChartDataEntry] = []
            for i in 0..<rainValues.count {
                let dataEntry = ChartDataEntry(x: Double(i), y: rainValues[i], icon: icons[i])
                raindataEntries.append(dataEntry)
            }
            
            let rainDataSet = LineChartDataSet(entries: raindataEntries, label: "")
            rainDataSet.drawIconsEnabled = true
            rainDataSet.drawValuesEnabled = false
            rainDataSet.drawCirclesEnabled = false
            rainDataSet.lineDashLengths = [5.0, 0.0]
            rainDataSet.setDrawHighlightIndicators(false)
            rainDataSet.setColor(NSUIColor(red: 159/255.0, green: 207/255.0, blue: 255/255.0, alpha: 1))
            rainDataSet.lineWidth = 1.0;
            rainDataSet.valueFont = UIFont.init(name: "Barlow-Regular", size: 12.0)!
            rainDataSet.formLineWidth = 1.0
            rainDataSet.formSize = 15.0
            rainDataSet.mode = .horizontalBezier
            rainDataSet.drawFilledEnabled = true
            rainDataSet.valueTextColor = NSUIColor.clear
            rainDataSet.fillColor = .clear
            var rainvals: [String] = []
            for value in rainValues {
                rainvals.append(String(format:"%d",Int(value)))
            }
            
            let rainvalueFormatter = LineChartValueFormatter()
            rainvalueFormatter.values = rainvals
            rainDataSet.valueFormatter = rainvalueFormatter
            chartData = LineChartData(dataSets: [chartDataSet,
                                                 rainDataSet,
                                                 self.getReferenceLineDataSetfor(referenceLine: referenceLine1),
                                                 self.getReferenceLineDataSetfor(referenceLine: referenceLine2),
                                                 self.getReferenceLineDataSetfor(referenceLine: referenceLine3)])
            
        }else{
            chartData = LineChartData(dataSets: [chartDataSet,
                                                 self.getReferenceLineDataSetfor(referenceLine: referenceLine1),
                                                 self.getReferenceLineDataSetfor(referenceLine: referenceLine2),
                                                 self.getReferenceLineDataSetfor(referenceLine: referenceLine3)])
        }
        
        
        let chartFormatter = LineChartFormatter(labels: xValues)
        
        let xAxis = XAxis()
        xAxis.valueFormatter = chartFormatter
        self.xAxis.valueFormatter = xAxis.valueFormatter
        self.xAxis.setLabelCount(5, force: false)
        self.xAxis.avoidFirstLastClippingEnabled = true
        self.xAxis.axisMaxLabels = 50
        self.xAxis.labelFont = UIFont.init(name: "Barlow-Regular", size: 12.0)!
        self.data = chartData
        
        self.setVisibleXRangeMaximum(5.0)
        self.dragYEnabled = false;
        self.dragXEnabled = true;
        
        var values: [String] = []
        for value in yValues {
            switch self.type {
            case .TMP:
                values.append(String(format:"%.0f%@",value, "\u{00B0}"))
            case .RN:
                values.append(String(format:"%.0f%%",value))
            default:
                values.append(String(format:"%.0f",value))
            }
        }
        
        let valueFormatter = LineChartValueFormatter()
        valueFormatter.values = values
        self.lineData?.setValueFormatter(valueFormatter)
        self.lineData?.setDrawValues(true)
    }
    
    public func setDailyLineChartData(xValues: [String], minTempValues: [Double],maxTempValues : [Double],rainValues :[Double],
                                      referenceLine1 : [Double],
                                      referenceLine2 : [Double],
                                      referenceLine3 : [Double] ,
                                      icons: [UIImage]) {
        
        
        //****** MIN Temperature Line ****** //
        var mindataEntries: [ChartDataEntry] = []
        for i in 0..<minTempValues.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: minTempValues[i], icon: icons[i])
            mindataEntries.append(dataEntry)
        }
        
        let color = NSUIColor(
            red: CGFloat(99) / 255.0,
            green: CGFloat(99) / 255.0,
            blue: CGFloat(99) / 255.0,
            alpha: CGFloat(1.0)
        )
        let minTempDataSet = LineChartDataSet(entries: mindataEntries, label: "")
        minTempDataSet.drawIconsEnabled = true
        minTempDataSet.lineDashLengths = [5.0, 0.0]
        minTempDataSet.setDrawHighlightIndicators(false)
        minTempDataSet.setColor(NSUIColor(red: 168/255.0, green: 127/255.0, blue: 127/255.0, alpha: 1))
        minTempDataSet.lineWidth = 1.0;
        minTempDataSet.valueFont = UIFont.init(name: "Barlow-Regular", size: 12.0)!
        minTempDataSet.formLineWidth = 1.0
        minTempDataSet.formSize = 15.0
        minTempDataSet.mode = .horizontalBezier
        
        minTempDataSet.drawCirclesEnabled = true
        minTempDataSet.drawFilledEnabled = true
        minTempDataSet.drawCircleHoleEnabled = false
        minTempDataSet.circleHoleRadius = 0
        minTempDataSet.circleRadius = 2
        minTempDataSet.setCircleColor(color)
        
        minTempDataSet.fillColor = NSUIColor.clear
        var minvalues: [String] = []
        for value in minTempValues {
            minvalues.append(String(format:"%.0f%@",value, "\u{00B0}"))
        }
        
        let minvalueFormatter = LineChartValueFormatter()
        minvalueFormatter.values = minvalues
        minTempDataSet.valueFormatter = minvalueFormatter
        
        
        //****** MAX Temperature Line ****** //
        var maxdataEntries: [ChartDataEntry] = []
        for i in 0..<maxTempValues.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: maxTempValues[i], icon: icons[i])
            maxdataEntries.append(dataEntry)
        }
        
        let maxTempDataSet = LineChartDataSet(entries: maxdataEntries, label: "")
        maxTempDataSet.drawIconsEnabled = true
        maxTempDataSet.drawCirclesEnabled = false
        maxTempDataSet.lineDashLengths = [5.0, 0.0]
        maxTempDataSet.setDrawHighlightIndicators(false)
        maxTempDataSet.setColor(NSUIColor(red: 168/255.0, green: 127/255.0, blue: 127/255.0, alpha: 1))
        maxTempDataSet.lineWidth = 1.0;
        maxTempDataSet.valueFont = UIFont.init(name: "Barlow-Regular", size: 12.0)!
        maxTempDataSet.formLineWidth = 1.0
        maxTempDataSet.formSize = 15.0
        maxTempDataSet.mode = .horizontalBezier
        
        maxTempDataSet.drawCirclesEnabled = true
        maxTempDataSet.drawFilledEnabled = true
        maxTempDataSet.drawCircleHoleEnabled = false
        maxTempDataSet.circleHoleRadius = 0
        maxTempDataSet.circleRadius = 2
        maxTempDataSet.setCircleColor(color)
        
        maxTempDataSet.fillColor = NSUIColor.clear
        var maxvalues: [String] = []
        for value in maxTempValues {
            maxvalues.append(String(format:"%.0f%@",value, "\u{00B0}"))
        }
        
        let maxvalueFormatter = LineChartValueFormatter()
        maxvalueFormatter.values = maxvalues
        maxTempDataSet.valueFormatter = maxvalueFormatter
        
        
        let maxRain = rainValues.max()
        var chartData = LineChartData()
        
        //****** RAIN Line ****** //
        var raindataEntries: [ChartDataEntry] = []
        for i in 0..<rainValues.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: rainValues[i], icon: icons[i])
            raindataEntries.append(dataEntry)
        }
        
        let rainDataSet = LineChartDataSet(entries: raindataEntries, label: "")
        rainDataSet.drawIconsEnabled = true
        rainDataSet.drawValuesEnabled = false
        rainDataSet.drawCirclesEnabled = false
        rainDataSet.lineDashLengths = [5.0, 0.0]
        rainDataSet.setDrawHighlightIndicators(false)
        rainDataSet.setColor(NSUIColor(red: 159/255.0, green: 207/255.0, blue: 255/255.0, alpha: 1))
        rainDataSet.lineWidth = 1.0;
        rainDataSet.valueFont = UIFont.init(name: "Barlow-Regular", size: 12.0)!
        rainDataSet.formLineWidth = 1.0
        rainDataSet.formSize = 15.0
        rainDataSet.mode = .horizontalBezier
        rainDataSet.drawFilledEnabled = true
        rainDataSet.setCircleColor(color)
        rainDataSet.valueTextColor = .clear//*** to hide the value labels on line
        rainDataSet.fillColor = .clear
        
        var rainvals: [String] = []
        for value in rainValues {
            rainvals.append(String(format:"%d",Int(value)))
        }
        
        let rainvalueFormatter = LineChartValueFormatter()
        rainvalueFormatter.values = rainvals
        rainDataSet.valueFormatter = rainvalueFormatter
        chartData = LineChartData(dataSets: [minTempDataSet,maxTempDataSet,rainDataSet,
                                             self.getReferenceLineDataSetfor(referenceLine: referenceLine1),
                                             self.getReferenceLineDataSetfor(referenceLine: referenceLine2),
                                             self.getReferenceLineDataSetfor(referenceLine: referenceLine3)])
        
        let chartFormatter = LineChartFormatter(labels: xValues)
        
        let xAxis = XAxis()
        xAxis.valueFormatter = chartFormatter
        self.xAxis.valueFormatter = xAxis.valueFormatter
        self.xAxis.setLabelCount(5, force: false)
        self.xAxis.avoidFirstLastClippingEnabled = true
        self.xAxis.axisMaxLabels = 70
        self.xAxis.labelFont = UIFont.init(name: "Barlow-Regular", size: 14.0)!
        
        self.data = chartData
        
        self.setVisibleXRangeMaximum(5.0)
        self.dragYEnabled = false;
        self.dragXEnabled = true;
        
        self.lineData?.setDrawValues(true)
        
    }
    
    public func getReferenceLineDataSetfor(referenceLine : [Double]) -> LineChartDataSet{
        
        var refLine3dataEntries: [ChartDataEntry] = []
        
        for i in 0..<referenceLine.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: referenceLine[i], icon: nil)
            refLine3dataEntries.append(dataEntry)
        }
        let refLine3_DataSet = LineChartDataSet(entries:refLine3dataEntries , label: "")
        refLine3_DataSet.drawIconsEnabled = false
        refLine3_DataSet.drawValuesEnabled = false
        refLine3_DataSet.lineDashLengths = [5.0, 2.0]
        refLine3_DataSet.setDrawHighlightIndicators(false)
        refLine3_DataSet.setColor(NSUIColor.lightGray, alpha: 0.7)
        refLine3_DataSet.lineWidth = 0.8;
        refLine3_DataSet.valueFont = UIFont.init(name: "Barlow-Regular", size: 12.0)!
        refLine3_DataSet.valueTextColor = NSUIColor.clear
        refLine3_DataSet.formLineWidth = 1.0
        refLine3_DataSet.formSize = 15.0
        refLine3_DataSet.mode = .horizontalBezier
        refLine3_DataSet.drawCirclesEnabled = false
        refLine3_DataSet.fillColor = NSUIColor.clear
        
        return refLine3_DataSet
    }
}
