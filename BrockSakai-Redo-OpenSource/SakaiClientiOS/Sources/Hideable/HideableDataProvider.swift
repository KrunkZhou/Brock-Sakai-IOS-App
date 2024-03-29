//
//  HideableDataProvider.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 7/11/18.
//  Modified by Krunk
//

import ReusableSource

/// A DataProvider to populate and manage data for a HideableTableManager.
/// In other words, it can provide data as needed based on the data's
/// visibility.
///
/// A HideableDataProvider allows Sakai data to be broken into Term-based
/// sections. However, it does not assume the terms already exist, like
/// HideableNetworkDataProvider
protocol HideableDataProvider: class, DataProvider {

    /// The list of academic semesters the student has attended. May include
    /// non-official Terms like "General", which are not tied to any specific
    /// semester. For HideableNetworkDataProvider, the terms are pulled from
    /// a TermService and will never include a non-official Term
    var terms: [Term] { get set }

    /// Every element in array corresponds to element in terms array and determines
    /// if that section is hidden or closed
    var isHidden: [Bool] { get set }

    func getTerm(for section: Int) -> Term?
    func isHidden(section: Int) -> Bool

    /// When reloading data, this data allows the Term configuration for the
    /// ReusableSource to be reset
    func resetTerms()

    func toggleHidden(for section: Int, to newVal: Bool)
}

extension HideableDataProvider {
    
    func isEmpty(section: Int) -> Bool {
        return numberOfItems(in: section) == 0
    }
    
    /// Helper method to determine how many rows to display based on
    /// whether section is hidden or not
    ///
    /// - Parameter section: the section for which rows will be displayed
    /// - Returns: the number of rows to be shown
    func numberOfItemsForHideableSection(section: Int) -> Int {
        if isHidden(section: section) {
            return 0
        }
        if isEmpty(section: section) {
            return 1
        }
        return numberOfItems(in: section)
    }

    func resetTerms() {
        terms = []
        isHidden = []
    }

    func isHidden(section: Int) -> Bool {
        guard section >= 0 && section < terms.count else {
            return true
        }
        return isHidden[section]
    }

    func getTerm(for section: Int) -> Term? {
        guard section >= 0 && section < terms.count else {
            return nil
        }
        return terms[section]
    }

    func toggleHidden(for section: Int, to newVal: Bool) {
        guard section >= 0 && section < terms.count else {
            return
        }
        isHidden[section] = newVal
    }
}
