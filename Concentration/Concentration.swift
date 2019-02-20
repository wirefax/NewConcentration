//
//  Concentration.swift
//  Concentration
//
//  Created by Maksym Logvin on 1/16/19.
//  Copyright © 2019 Maksym Logvin. All rights reserved.
//

//MARK: Фреймворк Foundation, а не UIKit, потому что модель всегда UI-независима
import Foundation

//MARK: Расширение протокола коллекции, который соблюдают такие типы как Array, String, CountableRange
//Позволяет выводить элемент коллекции только в том случае, если у коллекции только один элемент, в противном случае - nil
extension Collection {
    var oneAndOnly: Element? {
        return count == 1 ? first: nil
    }
}

//MARK: Расширение типа Массив для реализации алгоритма тасования карт Фишера-Йенса
//Цикл для всех элементов массива, включая последний
//Получение произвольного числа идекса случайного элемента массива
//Обмен значениями между текущим и полученным индексом
extension Array {
    mutating func shuffle() {
        if count < 2 {
            return
        }
        for i in indices.dropLast() {
            let diff = distance(from: i, to: endIndex)
            let j = index(i, offsetBy: diff.arc4random)
            swapAt(i,j)
    }
  }
}

//MARK: Расширение типа Время в котором мы определяем переменную sinceNow, которая делает отрицательное преобразование Date -> Int
extension Date {
    var sinceNow: Int {
        return -Int(self.timeIntervalSinceNow)
    }
}

class Concentration
{
    //MARK: Массив всех карт в игре, в начале он всегда пустой
    //Сущность Card находится в другом файле модели Card.swift в виде структуры, а не класса
    //Благодаря установке доступа мы можем смотреть на карты и использовать их в игре, но не давать изменять их свойства
    private (set) var cards = [Card]()
    
    //MARK: Переменная подсчета очков
    private (set) var score = 0
    
    //MARK: Переменная подсчета переворота карт
    private (set) var flipCount = 0
    
    //MARK: Множество уже ранее увиденных и не совпавших карт
    private var seenCards: Set<Int> = []
    
    //MARK: Структура бонусов и штрафов за совпадения и непопадания, максимальный временной штраф
    private struct Points {
        static let matchBonus = 20
        static let missMatchPenalty = 10
        static var maxTimePenalty = 10
    }
    
    //MARK: Две переменные, одна хранит время клика на карте, вторая - вычисляемая переменная, показывающая сколько прошло секунд с момента последнего клика
    private var dateClick: Date?
    private var timePenalty: Int {
        return min(dateClick?.sinceNow ?? 0, Points.maxTimePenalty)
    }
    
    //MARK: Переменная которая отслеживает ситуацию при которой только ОДНА карта на столе лежит лицевой стороной, и следующую выбранную карту нужно будет сравнивать с ней на совпадение
    //Тип переменной ОПЦИОНАЛ, потому что в тех ситуациях когда на столе нет карт с лицевой стороной или лежат две открытые карты, значение переменной - NOT SET
    //В любой момент времени можно получить индекс карты с лицевой стороной, который можно сравнить, а если значение NIL, то и делать ничего не нужно
    //Переменная реализована как вычисляемое свойство (computed property), если при просмотре всех карт в GET мы найдет только одну карту лицом вверх - возвращаем ее индекс, иначе - NIL (это значение является дефолтным при декларировании опционала! переменная получает его АВТОМАТИЧЕСКИ)
    //Реализация поиска идекса перевернутой карты через замыкание, основана на методе filter, который проверяет все элементы массива карты на соответствие одному параметру isFaceUp == true, и тот единственный индекс для кого это утверждение верно - присваивает в качестве значения indexOfOneAndOnlyFaceUpCard, в остальных случаях - когда таких карт нет или их больше 1 - возвращает nil
    //В SET мы ищем карту с индексом newValue и переворачиваем ее лицом, укладывая остальные лицом вниз
    //Переменная никогда нигде не запоминается, вместо этого каждый раз, когда ее запрашивают она вычисляется кодом внутри GET
    //А если значение переменной меняется извне, то выполняется код внутри SET (этой части у таких свойств может не быть, но GET всегда есть)
    private var indexOfOneAndOnlyFaceUpCard: Int? {
        get {
            //let faceUpCardIndices = cards.indices.filter {cards[$0].isFaceUp}
            //return faceUpCardIndices.count == 1 ? faceUpCardIndices.first : nil
            return cards.indices.filter{cards[$0].isFaceUp}.oneAndOnly
            /*var foundIndex: Int?
            for index in cards.indices {
                if cards[index].isFaceUp {
                    if foundIndex == nil {
                        foundIndex = index
                    } else {
                        return nil
                    }
                }
            }
            return foundIndex*/
        }
        
        set (newValue) {
            for index in cards.indices {
                cards [index].isFaceUp = (index == newValue)
            }
        }
    }
    
    
    //MARK: Метод выбора карты
    //В качестве передающего аргумента используется индекс карты в массиве cards
    //Первое условие - игнорирование совпавших карт с прозрачной заливкой, на них не обращаем внимание
    //Вся логика игры сосредоточена здесь!!!
    func chooseCard(at index:Int) {
        //Утверждение, в котором содержится информация о причине возможного аварийного завершения при отладке приложения с указанием неверного значения переменной
        //Если все индексы массива cards не содержат переданный аргумент "индекс", то приложение аварийно завершится с пояснительной надписью
        assert(cards.indices.contains(index), "Concentration.chooseCard(at: \(index)): choosen index not in the cards")
        if !cards[index].isMatched {
            flipCount += 1
            if let matchIndex = indexOfOneAndOnlyFaceUpCard, matchIndex != index {
                //check if cards match
                //MARK: Просматриваем все карты и смотрим, найдем ли мы только одну карту, которая лежит лицевой стороной вверх
                if cards[matchIndex] == cards[index] {
                    cards[matchIndex].isMatched = true
                    cards[index].isMatched = true
                     //Увеличение очков за совпадение карт
                    score += Points.matchBonus
                
                cards[index].isFaceUp = true
                //indexOfOneAndOnlyFaceUpCard = nil
            } else {
                 //Уменьшение очков за каждую увиденную и не совпавшую карту
                if seenCards.contains(index) {
                 score -= Points.missMatchPenalty
                
                if seenCards.contains(matchIndex) {
                    score -= Points.missMatchPenalty
                
                seenCards.insert(index)
                seenCards.insert(matchIndex)
                    
                score -= timePenalty
                    cards[index].isFaceUp = true
            } else {
                //either no cards or cards are face up
                /*for flipdownIndex in cards.indices {
                   cards[flipdownIndex].isFaceUp = false
                }
                cards[index].isFaceUp = true */
                indexOfOneAndOnlyFaceUpCard = index
            }
        }
    }
            }
            dateClick = Date()
        }
    }
    /*   if cards[index].isFaceUp {
     cards[index].isFaceUp = false
     } else {
     cards[index].isFaceUp = true
     } */
    
    //MARK: Метод сброса всех карт в изначальное состояние
    func resetGame() {
        flipCount = 0
        score = 0
        seenCards = []
        
        for index in cards.indices {
            cards[index].isFaceUp = false
            cards[index].isMatched = false
        }
        cards.shuffle()
    }
    
    //MARK: Инициализируем количество пар карт в игре
    //В него передается аргументом количество пар
    //Через цикл в пустой массив cards забиваются парные карты с уникальными ижентификаторами - которые инициализируются в структуре Card
    init (numberOfPairsOfCards: Int) {
        //Утверждение на случай если входяшее количество пар будет меньше или равно 0
        assert (numberOfPairsOfCards > 0, "Concentration.init(\(numberOfPairsOfCards)): you must have a least one pair of cards")
        for _ in 1...numberOfPairsOfCards {
        let card = Card()
       /*   let matchingCard = card
            cards.append(card)
            cards.append(matchingCard)*/
            cards += [card, card]
        }
        // TODO: Shuffle the cards
        cards.shuffle()
        //Моя реализация тасования карт для конкретного массива
        /*var randomCards = [Card]()
         for _ in cards.indices {
         let shuffle = cards.remove(at: cards.endIndex.arc4random)
         randomCards.append(shuffle)
         }
         cards = randomCards*/
    }
       
}

