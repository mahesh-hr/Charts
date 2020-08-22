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
            guard let secondValue = Int(secondaryValues[Int(entry.x)]), secondValue != 0 else {
                return ""
            }
            
            return secondaryValues[Int(entry.x)]
        }
    }
    
    private class LineChartFormatter: NSObject, IAxisValueFormatter {
        
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
    
    public func setLineChartData(xValues: [String], yValues: [Double], icons: [UIImage], extra: [String : Any]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<yValues.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: yValues[i], icon: icons[i])
            dataEntries.append(dataEntry)
        }
        
        let color = NSUIColor(
            red: CGFloat(99) / 255.0,
            green: CGFloat(99) / 255.0,
            blue: CGFloat(99) / 255.0,
            alpha: CGFloat(1.0)
        )
        let chartDataSet = LineChartDataSet(entries: dataEntries, label: "")
        chartDataSet.drawIconsEnabled = true
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.lineDashLengths = [5.0, 0.0]
        chartDataSet.setDrawHighlightIndicators(false)
        chartDataSet.setColor(color)
        chartDataSet.lineWidth = 1.0;
        chartDataSet.valueFont = UIFont.init(name: "Barlow-Regular", size: 12.0)!
        chartDataSet.formLineDashLengths = [5.0, 2.5]
        chartDataSet.formLineWidth = 1.0
        chartDataSet.formSize = 15.0
        chartDataSet.mode = .horizontalBezier
        chartDataSet.drawFilledEnabled = true
        chartDataSet.drawCircleHoleEnabled = true
        chartDataSet.circleHoleRadius = 2
        chartDataSet.circleRadius = chartDataSet.circleHoleRadius + 1
        chartDataSet.circleHoleColor = UIColor.white
        chartDataSet.setCircleColor(color)
        
        let gradientColors = [ChartColorTemplates.colorFromString("rgba(203,203,203,0)").cgColor,
                              ChartColorTemplates.colorFromString("rgba(203,203,203,1)").cgColor] as CFArray
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors, locations: nil);
        chartDataSet.fillAlpha = 1.0;
        chartDataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0)
        
        let chartData = LineChartData(dataSet: chartDataSet)
        
        let chartFormatter = LineChartFormatter(labels: xValues)
        
        let xAxis = XAxis()
        xAxis.valueFormatter = chartFormatter
        self.xAxis.valueFormatter = xAxis.valueFormatter
        self.xAxis.setLabelCount(5, force: false)
        self.xAxis.avoidFirstLastClippingEnabled = false
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
        if self.type == .RN {
            valueFormatter.secondaryValues = extra["secondaryValues"] as! [String]
        }
        self.lineData?.setValueFormatter(valueFormatter)
        self.lineData?.setDrawValues(true)
    }
}
