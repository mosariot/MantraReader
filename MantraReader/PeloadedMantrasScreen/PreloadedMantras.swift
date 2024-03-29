//
//  InitialMantraData.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 10.08.2020.
//

import Foundation

enum PreloadedMantras {
    enum MantraAttributes {
        case title
        case text
        case details
        case image
        case image_list
    }
    
    static let data: [[MantraAttributes: String]] = [
        [
            .title: String(localized: "Buddha Shakyamuni", comment: "Buddha Shakyamuni"),
            .details: String(localized: "Thanks to the repetition of this mantra all obscurations and hindrances go away, a person approaches the state of Enlightenment, receives inspiration, blessings, rapid progress on the path of perfection, and a connection is established with Buddha Shakyamuni.", comment: "Buddha Shakyamuni Description"),
            .image: "Buddha_Shakyamuni",
            .image_list: "Buddha_Shakyamuni_list"
        ],
        [
            .title: String(localized: "Buddha Medicine", comment: "Buddha Medicine"),
            .details: String(localized: "Reading the mantra creates a special vibration that affects energy channels, expands and purifies the aura, enhances vital energy. Including the mantra helps to transform negative emotions and obscurations.", comment: "Buddha Medicine Description"),
            .image: "Buddha_Medicine",
            .image_list: "Buddha_Medicine_list"
        ],
        [
            .title: String(localized: "Buddha Amitabha", comment: "Buddha Amitabha"),
            .details: String(localized: "Reading the mantra personifies the discriminating mind and bestows the yogic power of knowing each thing separately as well as all things in unity.", comment: "Buddha Amitabha Description"),
            .image: "Buddha_Amitabha",
            .image_list: "Buddha_Amitabha_list"
        ],
        [
            .title: String(localized: "Avalokitesvara", comment: "Avalokitesvara"),
            .details: String(localized: "Repetition of the mantra in concentration clears negative karma, affects all levels of the subconscious, reveals hidden talents, allows you to accumulate vast merits, develop compassion and kind-heartedness towards all living beings.", comment: "Avalokitesvara Description"),
            .image: "Avalokitesvara",
            .image_list: "Avalokitesvara_list"
        ],
        [
            .title: String(localized: "Vajrapani", comment: "Vajrapani"),
            .details: String(localized: "Reciting the mantra of the Bodhisattva Vajrapani with sincere good intentions helps to overcome various ailments, delusions, brings self-confidence, firm support in any endeavors, determination, purposefulness, increases the strength and capabilities of a person.", comment: "Vajrapani Description"),
            .image: "Vajrapani",
            .image_list: "Vajrapani_list"
        ],
        [
            .title: String(localized: "Vasundhara", comment: "Vasundhara"),
            .details: String(localized: "Reading the mantra bestows piously acquired wealth and also ensures that spiritual wisdom is accompanied by favorable circumstances - a high standard of living, longevity, and happiness.", comment: "Vasundhara Description"),
            .image: "Vasundhara",
            .image_list: "Vasundhara_list"
        ],
        [
            .title: String(localized: "Hayagriva", comment: "Hayagriva"),
            .details: String(localized: "Hayagriva's mantra prevents suicide, murder, protects against the action of harmful spirits and evil demons, promotes peace and tranquility in the soul. The mantra of the protector protects not only from spirits and evil demons, but also from backbiting and slander.", comment: "Hayagriva Description"),
            .image: "Hayagriva",
            .image_list: "Hayagriva_list"
        ],
        [
            .title: String(localized: "Manjusri", comment: "Manjusri"),
            .details: String(localized: "Reading the mantra dispels the roots of ignorance and defilement, develops wisdom, intelligence, assimilation of knowledge, strengthens memory, develops eloquence, allows you to control the mind and contributes to comprehending the true nature of all things.", comment: "Manjusri Description"),
            .image: "Manjusri",
            .image_list: "Manjusri_list"
        ],
        [
            .title: String(localized: "Green Tara", comment: "Green Tara"),
            .details: String(localized: "Green Tara is addressed as the embodiment of all enlightened ones, as a comforter, as a protector who quickly responds to a request for help, as a patronizing deity who shows compassion and love to all beings, comparable to a mother's care for her children.", comment: "Green Tara Description"),
            .image: "Green_Tara",
            .image_list: "Green_Tara_list"
        ],
        [
            .title: String(localized: "Vajrasattva", comment: "Vajrasattva"),
            .text: String(localized: "OM BENZA SATO SAMAYA MANUPALAYA BENZA SATO TENOPA TITA DRI DO MEBHAWA SUTO KAYO MEBHAWA SUPO KAYO MEBHAWA ANURAKTO MEBHAWA SARWA SIDDHI MEMTRAYATSA SARWA KARMA SUTSA METSI TAM SHRI YA KURU HUNG HA HA HA HA HO BHAGAWAN SARWA TATHAGATA BENZA MA ME MUNTSA BENZRI BHAWA MAHA SAMAYA SATO AH", comment: "Vajrasattva Text"),
            .details: String(localized: "The practice of the Vajrasattva mantra has the ability to purify the karma of not only this incarnation, but also many others, bring peace, alleviate the suffering of the reader or listener, remove spiritual obstacles and cause enlightenment in general.", comment: "Vajrasattva Description"),
            .image: "Vajrasattva",
            .image_list: "Vajrasattva_list"
        ],
        [
            .title: String(localized: "White Tara", comment: "White Tara"),
            .details: String(localized: "The mantra of White Tara is a request for longevity, and the use of this longevity for the benefit of all living beings as well (in other words, an increase in wisdom and, as a result, merit generated by good deeds).", comment: "White Tara Description"),
            .image: "White_Tara",
            .image_list: "White_Tara_list"
        ],
        [
            .title: String(localized: "Buddha Amitayus", comment: "Buddha Amitayus"),
            .details: String(localized: "The practice of the Buddha Amitayus mantra helps to prolong life and improve health.", comment: "Buddha Amitayus Description"),
            .image: "Buddha_Amitabha",
            .image_list: "Buddha_Amitabha_list"
        ],
        [
            .title: String(localized: "Yellow Dzambhala", comment: "Yellow Dzambhala"),
            .details: String(localized: "Recitation of the Yellow Dzambala mantra with full concentration increases well-being, wisdom, tolerance, vigilance and spiritual achievement, gives protection from difficulties and all negative things, helps to develop altruistic motivations.", comment: "Yellow Dzambhala Description"),
            .image: "Yellow_Dzambhala",
            .image_list: "Yellow_Dzambhala_list"
        ],
        [
            .title: String(localized: "Thousand Armed Avalokitesvara", comment: "Thousand Armed Avalokitesvara"),
            .details: String(localized: "The Compassion Buddha, the embodiment of the universal compassion of all enlightened beings. By relying on Thousand Armed Avalokitesvara we naturally increase our own compassion.", comment: "Thousand Armed Avalokitesvara Description"),
            .image: "Thousand_Avalokitesvara",
            .image_list: "Thousand_Avalokitesvara_list"
        ],
        [
            .title: String(localized: "Prajnaparamita", comment: "Prajnaparamita"),
            .details: String(localized: "Prajnaparamita mantra means complete deliverance from illusion and welcomes complete and final awakening, perfect wisdom.", comment: "Prajnaparamita Description"),
            .image: "Prajnaparamita",
            .image_list: "Prajnaparamita_list"
        ],
        [
            .title: String(localized: "Maytreya", comment: "Maytreya"),
            .details: String(localized: "Maitreya symbolizes the loving kindness of the Buddha as well as the aspect of vision, the sense of sight. He embodies the future Buddha, who will be reborn and appear before people. If the practitioner doesn’t succeed in achieving full enlightenment in this incarnation, the Maitreya mantra will bring him closer to the highest good in subsequent reincarnations.", comment: "Maytreya Description"),
            .image: "Maytreya",
            .image_list: "Maytreya_list"
        ],
        [
            .title: String(localized: "Vajrakilaya", comment: "Vajrakilaya"),
            .details: String(localized: "The Vajrakilaya mantra protects from any evil, removes obstacles, destroys hostile forces, relieves fear, jealousy, anger.", comment: "Vajrakilaya Description"),
            .image: "Vajrakilaya",
            .image_list: "Vajrakilaya_list"
        ],
        [
            .title: String(localized: "Guru Padmasambhava", comment: "Guru Padmasambhava"),
            .details: String(localized: "Guru Padmasambhava himself eloquently and extensively described the benefits of reciting this mantra: 'The essential Vajra Guru mantra, if it’s recited with unlimited aspiration as much as possible - one hundred, one thousand, ten thousand, one hundred thousand, ten million, one hundred million, and so on, will bring unimaginable benefits and strengths. Countries everywhere are protected from all epidemics, hunger, wars, armed violence, crop failure, bad omens and evil spells. The rains will come in due season, the harvests and livestock will be excellent, and the lands will prosper. In this life, in future lives, successful practitioners will meet me again and again - the best in reality, or in visions, the lowest in dreams'.", comment: "Guru Padmasambhava Description"),
            .image: "Guru_Padmasambhava",
            .image_list: "Guru_Padmasambhava_list"
        ],
        [
            .title: String(localized: "Parnashavari", comment: "Parnashavari"),
            .details: String(localized: "Meditation on Parnashavari and the practice of her mantra strengthens immunity and resistance to infectious diseases. Parnashavari's call declares that she prevents all epidemics, diseases and suffering.", comment: "Parnashavari Description"),
            .image: "Parnashavari",
            .image_list: "Parnashavari_list"
        ]
    ]
    
    static var sorted: [[MantraAttributes: String]] {
        self.data.sorted {
            guard
                let mantraTitle0 = $0[.title],
                let mantraTitle1 = $1[.title]
            else { return false }
            return mantraTitle0 < mantraTitle1
        }
    }
}
