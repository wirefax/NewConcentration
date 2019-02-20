//
//  Card.swift
//  Concentration
//
//  Created by Maksym Logvin on 1/16/19.
//  Copyright © 2019 Maksym Logvin. All rights reserved.
//

import Foundation

//MARK: Все свойства сущности "Карта"
//Рубашка "вверх/вниз"
//Совпала ли карта с "двойником", да/нет
//Уникальный идентификатор карты
struct Card: Hashable {
    
    //MARK: Заглушка для реализации протоколов Hashable и Equatable
    //Протоколы позволяют использовать тип Card в качестве хешируемого ключа в словаре эмоджи
    //А также сделать переменную identifier карты private, чтобы ее значение нельзя было менять извне
    var hashValue: Int {
        return identifier
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    //MARK: Все эти свойства связаны с индивидуальной картой
    var isFaceUp = false
    var isMatched = false
    private var identifier: Int
    
    //MARK: Это свойство связано только с этим конкретным типом (Utility type), и не может быть использовано через API как внешнее свойство типа
    private static var identifierFactory = 0
    
    //MARK: Метод специального типа, вспомогательная функция привязанная к типу, доступа извне структуры к ней нет
    //получает уникальный идентификатор и возращает другой уникальный идентификатор
    private static func getUniqueIdentifier() -> Int {
        identifierFactory += 1
        return identifierFactory
    }
    
    //MARK: Инициализация присваивания уникального идентификатора карте через метод getUniqueIdentifier
    init () {
        self.identifier = Card.getUniqueIdentifier()
    }
}
