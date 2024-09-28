//
//  TrashTypeModel.swift
//  Request
//
//  Created by Herrera Alba Eduardo Jose on 27/09/24.
//

import SwiftUI

struct TrashTypeIcon {
    let type: String
    let icon: String // Usamos el nombre del SF Symbol como cadena
    
    // Computed property para devolver una imagen de SF Symbol
    var iconImage: Image {
        Image(systemName: icon)
    }
}

// Lista de tipos de basura con los íconos correspondientes
let trashTypes: [TrashTypeIcon] = [
    TrashTypeIcon(type: "Plastic Bottle", icon: "drop.fill"),
    TrashTypeIcon(type: "Aluminum Can", icon: "building.2"),
    TrashTypeIcon(type: "Glass Bottle", icon: "drop.fill"),
    TrashTypeIcon(type: "Paper Waste", icon: "doc.fill"),
    TrashTypeIcon(type: "Cardboard Box", icon: "shippingbox.fill"),
    TrashTypeIcon(type: "Food Scrap", icon: "fork.knife"),
    TrashTypeIcon(type: "Yard Waste", icon: "leaf.fill"),
    TrashTypeIcon(type: "Electronic Waste", icon: "desktopcomputer"),
    TrashTypeIcon(type: "Styrofoam", icon: "recycle"),
    TrashTypeIcon(type: "Battery", icon: "battery.100"),
    TrashTypeIcon(type: "Hazardous Waste", icon: "exclamationmark.triangle.fill"),
    TrashTypeIcon(type: "Textile Waste", icon: "tshirt.fill"),
    TrashTypeIcon(type: "Medical Waste", icon: "bandage.fill"),
    TrashTypeIcon(type: "Oil Container", icon: "fuelpump.fill"),
    TrashTypeIcon(type: "Paint Can", icon: "paintbrush.fill")
]

let trashTypesString = trashTypes.map { $0.type }.joined(separator: ", ")
