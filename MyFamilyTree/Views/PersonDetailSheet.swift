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

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if let photoData = currentPerson.photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 72, height: 72)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill((currentPerson.sex == .male ? Theme.male : Theme.female).opacity(0.15))
                        .frame(width: 72, height: 72)
                        .overlay(
                            Text(currentPerson.avatarInitials)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(currentPerson.sex == .male ? Theme.male : Theme.female)
                        )
                }

                Text(currentPerson.name.isEmpty ? (isRussian ? "Без имени" : "No name") : currentPerson.name)
                    .font(.system(size: 18, weight: .bold))
                if !currentPerson.years.isEmpty {
                    Text(currentPerson.years)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                if !currentPerson.relation.isEmpty {
                    Text(currentPerson.relation)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.wine)
                }

                HStack(spacing: 18) {
                    if currentPerson.phone != nil { Image(systemName: "phone.fill") }
                    if currentPerson.whatsapp != nil { Image(systemName: "message.fill") }
                    if currentPerson.telegram != nil { Image(systemName: "paperplane.fill") }
                    if currentPerson.instagram != nil { Image(systemName: "camera.fill") }
                }
                .foregroundStyle(Theme.gold)
                .font(.system(size: 18))

                Spacer()

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
        .presentationDetents([.medium])
    }
}
