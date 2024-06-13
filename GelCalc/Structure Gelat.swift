import SwiftUI

struct Projecteur: Identifiable, Hashable {
    let id = UUID()
    let nom: String
    let largeur: Double
    let hauteur: Double
}

struct Resultat: Identifiable, Equatable {
    let id = UUID()
    let projecteur: Projecteur
    let reference: String
    let marque: String
    let type: String
    let nombreDeProjecteurs: Int
    let quantite: Int
}

struct CumulResultat: Identifiable {
    let id = UUID()
    let reference: String
    let marque: String
    let type: String
    let quantite: Int
}
