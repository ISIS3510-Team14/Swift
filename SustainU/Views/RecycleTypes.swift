struct RecycleTypeConfig {
    let title: String
    let iconName: String
    let fact: String
    let trashCanImageName: String
    let disposalInfo: String
    let extraInfo: String
}

struct RecycleTypes {
    static let configurations: [String: RecycleTypeConfig] = [
        "Paper": RecycleTypeConfig(
            title: "Paper",
            iconName: "paper_icon",
            fact: "Recycling one ton of paper saves 17 trees",
            trashCanImageName: "gray_trash_can",
            disposalInfo: "Paper is most of the time thrown in the gray trash can",
            extraInfo: "If you can you might want to remove any contaminants like plastic windows from envelopes before recycling."
        ),
        "Glass": RecycleTypeConfig(
            title: "Glass",
            iconName: "glass_icon",
            fact: "Glass can be endlessly recycled without losing quality.",
            trashCanImageName: "blue_trash_can",
            disposalInfo: "Glass is most of the time thrown in the blue trash can",
            extraInfo: "If you can, separate colored glass, as mixing them can reduce recyclability."
        ),
        "Plastic": RecycleTypeConfig(
            title: "Plastic",
            iconName: "plastic_icon",
            fact: "Plastics take up to 500 years to decompose.",
            trashCanImageName: "blue_trash_can",
            disposalInfo: "Plastic is most of the time thrown in the blue trash can",
            extraInfo: "Not all plastics are recyclable—check for symbols like 1 (PET) and 2 (HDPE)."
        ),
        "Metal": RecycleTypeConfig(
            title: "Metal",
            iconName: "metal_icon",
            fact: "Recycling aluminum saves 95% of the energy used to produce new metal.",
            trashCanImageName: "blue_trash_can",
            disposalInfo: "Metal is most of the time thrown in the blue trash can",
            extraInfo: "You might want to ensure metals are clean of food residue before recycling."
        )
    ]
}
