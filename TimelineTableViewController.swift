//
//  TimeLineTableViewController+UITableViewDataSource.swift
//  SAP-RAO-Beta
//
//  Created by appaiah ketolira ganapathy | Livin Dcruz on 25/04/22.
//

import Foundation
import UIKit
import SAPFiori
import Combine
import SnapKit

extension TimeLineTableViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rowCount = self.viewModel.sectionViewModels[section].timeLineCellViewModels.count
        return (rowCount > 0) ? rowCount : 1  //Show section emtpy row.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        self.viewModel.sectionViewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let section = self.viewModel.sectionViewModels[indexPath.section]

        guard !section.isEmptySection else {
            let cell = UITableViewCell()

            let label = UILabel(frame: .zero)
            label.font = .preferredFont(forTextStyle: .footnote)
            label.textColor = .preferredFioriColor(forStyle: .tertiaryLabel)
            label.text = "There are no scheduled store visits"

            cell.addSubview(label)

            label.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }

            cell.isUserInteractionEnabled = false

            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FUITimelineCell",
                                                       for: indexPath) as? FUITimelineCell else {
            return UITableViewCell()
        }

        let cellViewModel = section.timeLineCellViewModels[indexPath.row]

        cell.separatorLineView.isHidden = false

        cell.headlineText = cellViewModel.storeName
        cell.subheadlineText = cellViewModel.storeAddress
        cell.timestampText = cellViewModel.time
        cell.secondaryTimestampText = cellViewModel.timeInterval
        cell.statusImage = cellViewModel.isEmergency
        cell.subAttributeText = cellViewModel.contact
        cell.nodeImage = cellViewModel.timelineStatusIcon
        
        if cellViewModel.status == .complete {
            cell.backgroundColor = .preferredFioriColor(forStyle: .quarternaryFill)
        }
        setupCellAppearance(cell: cell)

        if indexPath.row == 0 { // Do not show separator for first row in each section.
            cell.separatorLineView.isHidden = true
        }

        cell.contentView.viewWithTag(120)?.removeFromSuperview()
        cell.contentView.viewWithTag(130)?.removeFromSuperview()
        
        if cellViewModel.status == .inProgress {
            let lineView = buildLineLayer()
            let dotLayer = buildDotLayer(radius: 6)

            cell.contentView.addSubview(lineView)
            cell.contentView.layer.addSublayer(dotLayer)

            cell.separatorLineView.isHidden = true
        }

        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator

        cell.separatorInset = UIEdgeInsets(top: .zero, left: .zero, bottom: .zero, right: 20)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = dequeueHeaderFooterView(tableView: tableView) else { return UIView() }
        let sectionViewModel = self.viewModel.sectionViewModels[section]
        header.titleLabel.text = sectionViewModel.sectionHeader

        header.titleLabel.font = .preferredFioriFont(forTextStyle: .subheadline)
        header.titleLabel.textColor = .preferredFioriColor(forStyle: .secondaryLabel)

        header.separators = .bottom
        header.separatorInset = UIEdgeInsets(top: .zero, left: 16, bottom: .zero, right: 16)

        return header
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        30.0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footer = dequeueHeaderFooterView(tableView: tableView) else { return nil }
        footer.style = .empty
        footer.setBackgroundColor(.preferredFioriColor(forStyle: .grey1))
        return footer
    }
    func dequeueHeaderFooterView(tableView: UITableView) -> FUITableViewHeaderFooterView? {
        guard let headerFooterView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: "FUITableViewHeaderFooterView") as? FUITableViewHeaderFooterView else {
            return nil
        }
        return headerFooterView
    }

    func setupCellAppearance(cell: FUITimelineCell) {

        cell.headlineLabel.font = .preferredFioriFont(forTextStyle: .headline, weight: .bold)
        cell.headlineLabel.textColor = .preferredFioriColor(forStyle: .primaryLabel)

        cell.subheadlineLabel.font = .preferredFioriFont(forTextStyle: .subheadline)
        cell.subheadlineLabel.textColor = .preferredFioriColor(forStyle: .secondaryLabel)

        cell.timestampLabel.font = .preferredFioriFont(forTextStyle: .caption1, weight: .bold)
        cell.timestampLabel.textColor = .preferredFioriColor(forStyle: .primaryLabel)

        cell.secondaryTimestampLabel.font = .preferredFioriFont(forTextStyle: .caption1)
        cell.secondaryTimestampLabel.textColor = .preferredFioriColor(forStyle: .primaryLabel)
    }

    func buildDotLayer(radius: CGFloat) -> CALayer {
        let dotPath = UIBezierPath(ovalIn: CGRect(x: 83, y: 0, width: radius, height: radius))
        let dotLayer = CAShapeLayer()
        dotLayer.path = dotPath.cgPath
        dotLayer.fillColor = UIColor.preferredFioriColor(forStyle: .tintColor).cgColor
        dotLayer.strokeColor = UIColor.preferredFioriColor(forStyle: .tintColor).cgColor
        dotLayer.anchorPointZ = 1
        dotLayer.name = "dotLayer"

        return dotLayer
    }

    func buildLineLayer() -> UIView {
        let lineViewFrame = CGRect(x: 87, y: 3, width: self.view.bounds.size.width, height: 1)

        let lineView = UIView(frame: lineViewFrame)
        lineView.backgroundColor = UIColor.preferredFioriColor(forStyle: .tintColor)
        lineView.tag = 120
        return lineView
    }

}
