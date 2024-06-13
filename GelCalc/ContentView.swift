import SwiftUI

struct ContentView: View {
    @State private var selectedProjecteur: Projecteur?
    @State private var nombreDeProjecteurs: String = ""
    @State private var referenceCouleur: String = ""
    @State private var selectedMarque: String = "LEE FILTER"
    @State private var resultats: [Resultat] = []
    @State private var cumulResultats: [CumulResultat] = []
    
    let marques = ["LEE FILTER", "ROSCO"]
    
    let projecteurs: [Projecteur] = [
        Projecteur(nom: "PAR64", largeur: 255, hauteur: 255),
        Projecteur(nom: "310", largeur: 215, hauteur: 215),
        Projecteur(nom: "329", largeur: 245, hauteur: 245),
        Projecteur(nom: "6XX SX", largeur: 180, hauteur: 180),
        Projecteur(nom: "7XX SX", largeur: 215, hauteur: 215),
        Projecteur(nom: "Aramis ", largeur: 270, hauteur: 270),
        Projecteur(nom: "ACP1001", largeur: 440, hauteur: 400)
    ]
    
    var body: some View {
        VStack {
            //            HStack {
            Text("GelCalc")
                .font(.largeTitle)
            //            }
            Text("Edition BRAME")
            
                .padding(1)
            
            HStack {
                VStack {
                    Text("Projecteur")
                    Picker("", selection: $selectedProjecteur) {
                        ForEach(projecteurs) { projecteur in
                            Text(projecteur.nom).tag(projecteur as Projecteur?)
                        }
                    }
                }
                VStack {
                    Text("Quantité")
                    TextField("QTE", text: $nombreDeProjecteurs)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.trailing)
                        .frame(width: 100)
                }
                
                VStack {
                    Text("Référence")
                    TextField("REF", text: $referenceCouleur)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)
                        .frame(width: 100)
                }
            }
                        .padding()
            
            HStack {
                VStack {
                    Picker("", selection: $selectedMarque) {
                        ForEach(marques, id: \.self) { marque in
                            Text(marque)
                        }
                    }
                }
                .frame(width: 120)
                
                Button("Ajouter") {
                    ajouterResultat()
                    calculerCumul()
                }
            }
            .padding()
            
            Text("Besoins")
                .font(.headline)
            
            List {
                ForEach(resultats) { resultat in
                    HStack {
                        Text("\(resultat.nombreDeProjecteurs) x \(resultat.projecteur.nom) // \(resultat.marque) - \(resultat.reference)")
                        Spacer()
                        Text("\(resultat.quantite) \(resultat.type == "Feuille" ? "Feuille(s)" : "Rouleau(x)")")
                        Button(action: {
                            supprimerResultat(resultat)
                        }) {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            
            Text("Totaux Cumulés par référence")
                .font(.headline)
            
            List(cumulResultats) { cumul in
                HStack {
                    Text("\(cumul.marque) - \(cumul.reference)")
                    Spacer()
                    Text("\(cumul.quantite) \(cumul.type == "Feuille" ? "Feuille(s)" : "Rouleau(x)")")
                }
            }
            
            Text("Référence LA BS :")
            Text("Lee Filter FLxxx ou RLxxx - Rosco FSxxx-050 ou RSxxx")
        }
        .padding()
        .frame(width: 600, height: 800)  // Définir la largeur et la hauteur de la vue
    }
    
    func ajouterResultat() {
        guard let projecteur = selectedProjecteur,
              let nombre = Int(nombreDeProjecteurs) else {
            return
        }
        
        // Calculer le nombre de découpes possibles par feuille et rouleau
        let decoupesParFeuille: Int
        let decoupesParRouleau: Int
        
        if selectedMarque == "LEE FILTER" {
            decoupesParFeuille = (Int(1220 / projecteur.largeur)) * (Int(530 / projecteur.hauteur))
            decoupesParRouleau = (Int(1220 / projecteur.largeur)) * (Int(7620 / projecteur.hauteur))
        } else {
            decoupesParFeuille = (Int(1000 / projecteur.largeur)) * (Int(610 / projecteur.hauteur))
            decoupesParRouleau = (Int(7620 / projecteur.largeur)) * (Int(610 / projecteur.hauteur))
        }
        
        // Calculer le nombre de feuilles et rouleaux nécessaires
        let quantiteFeuilles = Int(ceil(Double(nombre) / Double(decoupesParFeuille)))
        let quantiteRouleaux = Int(ceil(Double(nombre) / Double(decoupesParRouleau)))
        
        let reference = "\(referenceCouleur)"
        
        let optimalQuantite: Int
        let optimalType: String
        
        if quantiteFeuilles > quantiteRouleaux {
            optimalQuantite = quantiteRouleaux
            optimalType = "Rouleau"
        } else {
            optimalQuantite = quantiteFeuilles
            optimalType = "Feuille"
        }
        
        let resultat = Resultat(projecteur: projecteur, reference: reference, marque: selectedMarque, type: optimalType, nombreDeProjecteurs: nombre, quantite: optimalQuantite)
        
        resultats.append(resultat)
        
        // Réinitialiser les champs
        nombreDeProjecteurs = ""
        referenceCouleur = ""
    }
    
    func supprimerResultat(_ resultat: Resultat) {
        if let index = resultats.firstIndex(of: resultat) {
            resultats.remove(at: index)
            calculerCumul()
        }
    }
    
    func calculerCumul() {
        var cumulDictionary: [String: (quantite: Int, marque: String, type: String)] = [:]
        
        for resultat in resultats {
            let key = "\(resultat.reference)-\(resultat.marque)-\(resultat.type)"
            
            if let existingData = cumulDictionary[key] {
                cumulDictionary[key] = (existingData.quantite + resultat.quantite, resultat.marque, resultat.type)
            } else {
                cumulDictionary[key] = (resultat.quantite, resultat.marque, resultat.type)
            }
        }
        
        cumulResultats = cumulDictionary.map { (key, value) -> CumulResultat in
            let components = key.split(separator: "-")
            let reference = String(components[0])
            let marque = value.marque
            let type = value.type
            let quantite = value.quantite
            
            return CumulResultat(reference: reference, marque: marque, type: type, quantite: quantite)
        }
    }
    
    func colorForReference(_ reference: String) -> Color {
        // Logique simplifiée pour déterminer la couleur en fonction de la référence
        switch reference.lowercased() {
        case "red":
            return .red
        case "blue":
            return .blue
        case "green":
            return .green
        case "yellow":
            return .yellow
        case "orange":
            return .orange
        case "purple":
            return .purple
        default:
            return .gray
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
