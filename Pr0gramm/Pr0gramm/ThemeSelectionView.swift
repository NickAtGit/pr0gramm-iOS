import SwiftUI

struct ThemeSelectionView: View {
    @AppStorage(#keyPath(AppSettings.selectedTheme)) private var selectedTheme: Int = AppSettings.selectedTheme

    let themes = ["Blau", "Orange", "Grün", "Pink", "Gelb"]

    var body: some View {
        Picker("Theme", selection: $selectedTheme) {
            ForEach(0 ..< themes.count, id: \.self) {
                Text(self.themes[$0])
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: selectedTheme) { newValue in
            Theming.applySelectedPersistedTheme()
        }
    }
}

#Preview {
    ThemeSelectionView()
}
