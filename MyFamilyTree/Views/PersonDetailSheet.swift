import SwiftUI
import UIKit

struct PersonDetailSheet: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) var dismiss
    let person: Person

    @State private var editMode: PersonFormMode?
    @State private var showDeleteBlockedAlert = false
    @State private var showDeleteConfirm = false

    private var isRussian: Bool { app.lang == .ru }

    private var currentPerson: Person {
        app.people.first(where: { $0.id == person.id }) ?? person
    }

    private func digitsOnly(_ s: String) -> String {
        s.filter { $0.isNumber || $0 == "+" }
    }

    private func handle(_ s: String) -> String {
        var t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.hasPrefix("@") { t.removeFirst() }
        return t
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let photoData = currentPerson.photoData, let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Theme.gold, lineWidth: 3))
                    } else {
                        Circle()
                            .fill((currentPerson.sex == .male ? Theme.male : Theme.female).opacity(0.15))
                            .frame(width: 150, height: 150)
                            .overlay(
                                Text(currentPerson.avatarInitials)
                                    .font(.system(size: 46, weight: .bold))
                                    .foregroundStyle(currentPerson.sex == .male ? Theme.male : Theme.female)
                            )
                            .overlay(Circle().stroke(currentPerson.sex == .male ? Theme.male : Theme.female, lineWidth: 3))
                    }

                    Text(currentPerson.name.isEmpty ? (isRussian ? "Без имени" : "No name") : currentPerson.name)
                        .font(.system(size: 20, weight: .bold))
                    if !currentPerson.years.isEmpty {
                        Text(currentPerson.years)
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    if !currentPerson.relation.isEmpty {
                        Text(currentPerson.relation)
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.wine)
                    }

                    contactButtons

                    Button {
                        editMode = .edit(currentPerson)
                    } label: {
                        Text(isRussian ? "Изменить" : "Edit")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.gold)
                    .padding(.horizontal, 24)

                    if currentPerson.role != .root {
                        Button(role: .destructive) {
                            if app.canRemove(currentPerson.id) {
                                showDeleteConfirm = true
                            } else {
                                showDeleteBlockedAlert = true
                            }
                        } label: {
                            Text(isRussian ? "Удалить" : "Delete")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                }
                .padding(.top, 32)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isRussian ? "Закрыть" : "Close") { dismiss() }
                }
            }
            .alert(isRussian ? "Удалить этого человека?" : "Delete this person?", isPresented: $showDeleteConfirm) {
                Button(isRussian ? "Отмена" : "Cancel", role: .cancel) {}
                Button(isRussian ? "Удалить" : "Delete", role: .destructive) {
                    app.removePerson(currentPerson.id)
                    dismiss()
                }
            }
            .alert(isRussian ? "Нельзя удалить" : "Can't delete", isPresented: $showDeleteBlockedAlert) {
                Button(isRussian ? "Понятно" : "OK", role: .cancel) {}
            } message: {
                Text(isRussian
                     ? "У этого человека есть дети в дереве — сначала удалите их, потом можно будет удалить и его."
                     : "This person has children in the tree — remove them first before you can delete this person.")
            }
        }
        .sheet(item: $editMode) { mode in
            AddPersonSheet(mode: mode)
        }
        .presentationDetents([.large])
    }

    @ViewBuilder
    private var contactButtons: some View {
        let buttonSize: CGFloat = 64
        let iconSize: CGFloat = 28

        HStack(spacing: 14) {
            if let phone = currentPerson.phone, !phone.isEmpty,
               let url = URL(string: "tel:\(digitsOnly(phone))") {
                Link(destination: url) { contactIcon("phone.fill", size: buttonSize, iconSize: iconSize) }
            }
            if let phone = currentPerson.phone, !phone.isEmpty,
               let url = URL(string: "sms:\(digitsOnly(phone))") {
                Link(destination: url) { contactIcon("bubble.left.fill", size: buttonSize, iconSize: iconSize) }
            }
            if let wa = currentPerson.whatsapp, !wa.isEmpty,
               let url = URL(string: "https://wa.me/\(digitsOnly(wa).replacingOccurrences(of: "+", with: ""))") {
                Link(destination: url) { contactIcon("message.fill", size: buttonSize, iconSize: iconSize) }
            }
            if let tg = currentPerson.telegram, !tg.isEmpty,
               let url = URL(string: "https://t.me/\(handle(tg))") {
                Link(destination: url) { contactIcon("paperplane.fill", size: buttonSize, iconSize: iconSize) }
            }
            if let ig = currentPerson.instagram, !ig.isEmpty,
               let url = URL(string: "https://instagram.com/\(handle(ig))") {
                Link(destination: url) { contactIcon("camera.fill", size: buttonSize, iconSize: iconSize) }
            }
        }
    }

    private func contactIcon(_ name: String, size: CGFloat, iconSize: CGFloat) -> some View {
        Image(systemName: name)
            .font(.system(size: iconSize))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(Theme.gold)
            .clipShape(Circle())
    }
}
