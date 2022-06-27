//
//  NewsData.swift
//  autodocTest
//
//  Created by Dmitry Martynov on 25.06.2022.
//

import Foundation

struct NewsItemData: Codable, Identifiable {
    
    let id: Int
    let title: String
    let description: String
    let publishedDate: String
    let url: String
    let fullUrl: String
    let titleImageUrl: String?
    let categoryType: String
    
}

/*
 
 {
     "news": [
         {
             "id": 6912,
             "title": "Peugeot 408 Coupe 2023 для тех, кто устал от скучных семейных автомобилей",
             "description": "Компания Peugeot решила не оставаться в стороне от самой популярной сегодня дизайнерской тенденции",
             "publishedDate": "2022-06-24T00:00:00",
             "url": "avto-novosti/peugeot _coupe",
             "fullUrl": "https://www.autodoc.ru/avto-novosti/peugeot _coupe",
             "titleImageUrl": "https://file.autodoc.ru/news/avto-novosti/1456586202_1.jpg",
             "categoryType": "Автомобильные новости"
         }
     ],
     "totalCount": 905
 }
 
 */
