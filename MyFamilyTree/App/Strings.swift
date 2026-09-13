import Foundation

// Mirrors the Lang.kt bilingual-strings pattern already used across the
// Android portfolio, so this file stays instantly recognizable to anyone
// who has worked on the Kotlin side.

enum Lang: String {
    case ru, en
}

enum L: String {
    case treeTitle, peopleTitle, exportTitle, settingsTitle
    case tabTree, tabPeople, tabExport, tabSettings
    case exes, search
    case proTitle, proSub, proActiveTitle, proActiveSub, buyPro, restore
    case watermarkNote, removeInPro, exportBtn, save, cancel, close
    case limitTitle, limitText, limitBuy, later, freeInfo1, freeInfo2
    case langLabel, addTitle, langGroup, freeGroup
    case fieldFullName, fieldBirth, fieldDeath, fieldRelation, fieldPhoto, fieldContacts
    case relChild, relSpouse, relParent
    case formatPDF, formatPNG, paperSize
}

enum Strings {
    private static let ru: [L: String] = [
        .treeTitle: "Моё древо", .peopleTitle: "Все люди", .exportTitle: "Экспорт", .settingsTitle: "Настройки",
        .tabTree: "Древо", .tabPeople: "Люди", .tabExport: "Экспорт", .tabSettings: "Настройки",
        .exes: "бывшие браки", .search: "Поиск по имени",
        .proTitle: "Моё древо PRO", .proSub: "Без лимита в 7 человек и без водяного знака на экспорте",
        .proActiveTitle: "PRO активен", .proActiveSub: "Спасибо за поддержку — лимит и водяной знак сняты.",
        .buyPro: "Купить PRO", .restore: "Восстановить покупку",
        .watermarkNote: "Бесплатная версия — экспорт с водяным знаком.", .removeInPro: "Убрать в PRO →",
        .exportBtn: "Экспортировать", .save: "Сохранить", .cancel: "Отмена", .close: "Закрыть",
        .limitTitle: "Достигнут лимит FREE", .limitText: "В бесплатной версии можно добавить до 7 человек. Снимите ограничение с помощью PRO.",
        .limitBuy: "Купить PRO за $4.99", .later: "Позже", .freeInfo1: "До 7 человек в дереве", .freeInfo2: "Экспорт с водяным знаком «Моё древо»",
        .langLabel: "Язык интерфейса", .addTitle: "Новый человек", .langGroup: "Язык", .freeGroup: "О тарифе FREE",
        .fieldFullName: "ФИО", .fieldBirth: "Дата рождения", .fieldDeath: "Дата смерти",
        .fieldRelation: "Кем приходится", .fieldPhoto: "Фото", .fieldContacts: "Контакты (необязательно)",
        .relChild: "Ребёнок", .relSpouse: "Супруг(а)", .relParent: "Родитель",
        .formatPDF: "PDF", .formatPNG: "PNG", .paperSize: "Размер листа",
    ]

    private static let en: [L: String] = [
        .treeTitle: "My Family Tree", .peopleTitle: "All People", .exportTitle: "Export", .settingsTitle: "Settings",
        .tabTree: "Tree", .tabPeople: "People", .tabExport: "Export", .tabSettings: "Settings",
        .exes: "former marriages", .search: "Search by name",
        .proTitle: "My Family Tree PRO", .proSub: "No 7-person limit and no watermark on export",
        .proActiveTitle: "PRO active", .proActiveSub: "Thanks for your support — the limit and watermark are removed.",
        .buyPro: "Buy PRO", .restore: "Restore purchase",
        .watermarkNote: "Free version — export includes a watermark.", .removeInPro: "Remove with PRO →",
        .exportBtn: "Export", .save: "Save", .cancel: "Cancel", .close: "Close",
        .limitTitle: "FREE limit reached", .limitText: "The free version allows up to 7 people. Remove the limit with PRO.",
        .limitBuy: "Buy PRO for $4.99", .later: "Later", .freeInfo1: "Up to 7 people in the tree", .freeInfo2: "Export carries a \u{201C}My Family Tree\u{201D} watermark",
        .langLabel: "Interface language", .addTitle: "New person", .langGroup: "Language", .freeGroup: "About FREE",
        .fieldFullName: "Full name", .fieldBirth: "Date of birth", .fieldDeath: "Date of death",
        .fieldRelation: "Relation", .fieldPhoto: "Photo", .fieldContacts: "Contacts (optional)",
        .relChild: "Child", .relSpouse: "Spouse", .relParent: "Parent",
        .formatPDF: "PDF", .formatPNG: "PNG", .paperSize: "Paper size",
    ]

    static func t(_ key: L, _ lang: Lang) -> String {
        (lang == .ru ? ru[key] : en[key]) ?? key.rawValue
    }
}
