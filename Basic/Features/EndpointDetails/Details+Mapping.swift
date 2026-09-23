import Foundation

extension User {
    var details: Details {
        Details(icon: avatar ?? "person.fill",
                title: name,
                subtitle: email,
                sections: [
                    DetailsSection(title: "Contact", rows: [
                        DetailsRow(title: "Username", value: username),
                        DetailsRow(title: "Email", value: email),
                        DetailsRow(title: "Phone", value: phone),
                        DetailsRow(title: "Website", value: website)
                    ]),
                    DetailsSection(title: "Address", rows: [
                        DetailsRow(title: "Street", value: address.street),
                        DetailsRow(title: "Suite", value: address.suite),
                        DetailsRow(title: "City", value: address.city),
                        DetailsRow(title: "Zipcode", value: address.zipcode),
                        DetailsRow(title: "Geo", value: "\(address.geo.lat), \(address.geo.lng)")
                    ]),
                    DetailsSection(title: "Company", rows: [
                        DetailsRow(title: "Name", value: company.name),
                        DetailsRow(title: "Catch Phrase", value: company.catchPhrase),
                        DetailsRow(title: "BS", value: company.bs)
                    ])
                ])
    }
}

extension Post {
    var details: Details {
        Details(icon: "doc.text.fill",
                title: title,
                subtitle: "Post #\(id)",
                sections: [
                    DetailsSection(title: "Post", rows: [
                        DetailsRow(title: "ID", value: "\(id)"),
                        DetailsRow(title: "User ID", value: "\(userId)")
                    ]),
                    DetailsSection(title: "Body", rows: [
                        DetailsRow(title: "Text", value: body)
                    ])
                ])
    }
}
