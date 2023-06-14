
import SwiftUI

struct ThemeSelectionView: View {
    @AppStorage("selectedTheme") private var selectedTheme: Int = 0

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

struct ThemeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeSelectionView()
    }
}
