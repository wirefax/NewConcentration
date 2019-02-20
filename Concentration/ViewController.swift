//
//  ViewController.swift
//  Concentration
//
//  Created by Maksym Logvin on 1/9/19.
//  Copyright © 2019 Maksym Logvin. All rights reserved.
//

import UIKit

//MARK: Расширение для Integer типа позволяет получить случайное целое число в диапазоне от 0 до указанной переменной
//Если число меньше 0, то получаем рандомное число по модулю
//Если равно 0, то ничего не рандомизируем
extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}


class ViewController: UIViewController {

    //MARK: Переменная-делегат,использующая все свойства и методы сущности Cards (БОЛЬШАЯ ЗЕЛЕНАЯ СТРЕЛКА для разговора Контроллера с Моделью)
    //+1 используется на случай нечетного количества карт для округления парных карт
    //А так было бы достаточно подсчитать количество кнопок и поделить его пополам, чтобы получить количество пар
    //Так как game это свойство ViewController, оно инициализируется перед тем как self становится доступным
    //Использование ленивого ключа lazy не инициализирует это свойство дл первого обращения к нему, и предотвращает замкнутый круг
    //Для lazy переменных использовать наблюдатели свойств НЕЛЬЗЯ
    //Эту переменную можно упростить через ввод вычисляемого свойства "количество пар карт"
    /*lazy var game = Concentration(numberOfPairsOfCards: (cardButtons.count + 1)/2)*/
    //Так как наша модель тесно связана с нашим UI, мы делаем ее доступ не-public
    private lazy var game = Concentration (numberOfPairsOfCards: numberOfPairsCards)
    
    //MARK: Вычисляемое свойство, возвращающее вычисленное значение, каждый раз когда к нему обращаются
    //Так как SET нет, это простое "read only" свойство, поэтому использование GET не обязательно
    var numberOfPairsCards: Int {
                    return (cardButtons.count + 1) / 2
           }
    
    //MARK: Глобальная переменная для updateViewFromModel
    //В нее передается идентификатор текущей темы, чтобы изменить цвет оборотной стороны карты
    //var faceDownColor: UIColor = .orange
    
    
    //MARK: Свойство меняющее тему при нажатии кнопки New Game
    //ДОРАБОТАТЬ!!!!
    /*var randomIndex: Int = 0 {
        didSet {
            
            switch randomIndex {
            case 0:
                for index in cardButtons.indices {
                    let button = cardButtons[index]
                    button.backgroundColor = .orange
                }
                faceDownColor = .orange
                view.backgroundColor = UIColor.black
            case 1:
                for index in cardButtons.indices {
                    let button = cardButtons[index]
                    button.backgroundColor = .brown
                }
                faceDownColor = .brown
                view.backgroundColor = UIColor.lightGray
            case 2:
                for index in cardButtons.indices {
                    let button = cardButtons[index]
                    button.backgroundColor = .magenta
                }
                faceDownColor = .magenta
                view.backgroundColor = UIColor.darkGray
            case 3:
                for index in cardButtons.indices {
                    let button = cardButtons[index]
                    button.backgroundColor = .purple
                }
                faceDownColor = .purple
                view.backgroundColor = UIColor.cyan
            case 4:
                for index in cardButtons.indices {
                    let button = cardButtons[index]
                    button.backgroundColor = .yellow
                }
                faceDownColor = .yellow
                view.backgroundColor = UIColor.green
            case 5:
                for index in cardButtons.indices {
                    let button = cardButtons[index]
                    button.backgroundColor = .blue
                }
                faceDownColor = .blue
                view.backgroundColor = UIColor.red
            default:
                for index in cardButtons.indices {
                    let button = cardButtons[index]
                    button.backgroundColor = .black
                }
                faceDownColor = .black
                view.backgroundColor = UIColor.white
            }
        }
    }*/
    
    //MARK: Инициализатор счетчика карт
    //didSet - Наблюдатель свойства (Property Observer)
    //При каждом изменении значения счетчика метка получает обновленное значение и выводит его в тексте метке
    //Можно получать значение переменной, но не устанавливать извне, так как это наша внутренняя реализация при переворотах карты
    //Создаем текст с аттрибутами, используя словарь с ключем типа из Objective-C (вынесли в отдельную функцию)
    /*private (set) var flipCount = 0 {
        didSet {
            updateFlipCountLabel()
        }
    }*/
    //Перенесли переменную из Представления в Модель
    
    
    //MARK: Функция для счетчика карт, изменяющая аттрибуты текста метки
    //вынесена за пределы didSet для инициализации при запуске приложения
    //если оставить ее внутри переменной-счетчика, аттрибуты текста метки будут меняться только при изменении состояния, т.е. при нажатии на карту
    private func updateFlipCountLabel () {
        let attributes: [NSAttributedString.Key: Any] = [.strokeWidth: 5.0, .strokeColor: UIColor.orange]
        let attributedString = NSAttributedString (string: "Flips: \(game.flipCount)", attributes: attributes)
        flipCountLabel.attributedText = attributedString
    }
    
  
    
    //MARK: Рабочий масссив эмоджи
    private var emojiChoises = ["👻", "🎃", "💀", "🤡", "😈", "🤖", "👹", "👺", "👽", "☠️", "👿", "💩", "👾"]
    
    //MARK: Две глобальные переменные отвечающие за цвет рубашек карт и цвет фона
    private var backgroundColor = UIColor.black
    private var cardBackColor = UIColor.orange
    
    //MARK: Вложенная структура Theme (вариант решения задачи по смене рубашек карт и цвета фона через структуры)
    private struct Theme {
        var name: String
        var emojis: [String]
        var viewColor: UIColor
        var cardColor: UIColor
    }
    
    //MARK: Словарь из массивов эмоджи, используемых в качестве тематических
    private var emojiThemes: [Theme] = [
        Theme(name: "Halloween", emojis: ["👻", "🎃", "💀", "🤡", "😈", "🤖", "👹", "👺", "👽", "☠️", "👿", "💩", "👾"], viewColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), cardColor: #colorLiteral(red: 0.9273878932, green: 0.2360441387, blue: 0.100830622, alpha: 1)),
        Theme(name: "Animals", emojis: ["🐶", "🐱", "🐭", "🦊", "🐻", "🐼", "🐷", "🐸", "🐮", "🐵", "🐰", "🐯", "🦁"], viewColor: #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1), cardColor: #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)),
        Theme(name: "Fruits", emojis: ["🍏", "🍅", "🍒", "🍇", "🌽", "🥝", "🍊", "🥥", "🍌", "🍓", "🍋", "🌶", "🥑"], viewColor: #colorLiteral(red: 0.1921568662, green: 0.007843137719, blue: 0.09019608051, alpha: 1), cardColor: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)),
        Theme(name: "Zodiac", emojis: ["♈️", "♉️", "♊️", "♋️", "♌️", "♍️", "♎️", "♏️", "♐️", "♑️", "♒️", "♓️", "⚛️"], viewColor: #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1), cardColor: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)),
        Theme(name: "Flags", emojis: ["🇧🇬", "🇦🇿", "🇧🇾", "🇷🇼", "🇺🇦", "🇸🇱", "🇵🇹", "🇺🇸", "🏴󠁧󠁢󠁷󠁬󠁳󠁿", "🇬🇧", "🇹🇷", "🇰🇷", "🇵🇦"], viewColor: #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1), cardColor: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)),
        Theme(name: "Sports", emojis: ["⚽️", "🏀", "🏈", "⚾️", "🎾", "🏐", "🏉", "🎱", "🥊", "🏓", "🏸", "⛸", "🏹"], viewColor: #colorLiteral(red: 0.3176470697, green: 0.07450980693, blue: 0.02745098062, alpha: 1), cardColor: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1))
    ]
    
    //MARK: Индекс темы, как только он меняется рабочему массиву присваивается содержимое переменной из структуры, соответствующей теме
    //Изменяется цвет рубашки карт и фона
    //Обнуляем словарь эмоджи для карт
    private var indexTheme = 0 {
        didSet {
            print(indexTheme, emojiThemes [indexTheme].name)
            titleLabel.text = emojiThemes [indexTheme].name
            
            emojiChoises = emojiThemes[indexTheme].emojis
            backgroundColor = emojiThemes[indexTheme].viewColor
            cardBackColor = emojiThemes[indexTheme].cardColor
            
            emoji = [Card: String]()
            
            updateAppearance()
        }
    }
    
    //MARK: Метод смены цветов, работает только при смене темы
    private func updateAppearance() {
        view.backgroundColor = backgroundColor
        flipCountLabel.textColor = cardBackColor
        titleLabel.textColor = cardBackColor
        scoreLabel.textColor = cardBackColor
        newGameButton.setTitleColor(backgroundColor, for: .normal)
        newGameButton.backgroundColor = cardBackColor
    }
    
    //MARK: Вычисляемый массив ключей словаря с Темами
    /*private var keys: [String] {
        return Array(emojiThemes.keys)
    }*/
    
    //MARK: Создаем пустой словарь (Dictionary) для эмоджи, в качестве ключа будет использоваться уникальный идентификатор карты identifier
    //Так как словарь эмоджи мы создаем "на лету", мы не можем позволить вносить в него свои изменения
    private var emoji = [Card:String]()
    
    // MARK: Функция поиска в словаре эмоджи, входящий аргумент типа Card с уникальным идентификатором
    //Поиск в словаре всегда возращает ОПЦИОНАЛ, так как там может и не быть этого значения
    //Эквивалентый код в конце метода - отвечает за вывод эмоджи соответствующего входящему идентификатору
    //Первая половина метода - заполняем пустой словарь рандомными эмоджи из массива эмоджиков emojiChoises
    //Заполнение идет "по требованию" конкретной карты, а не полностью все и скопом
    private func emoji (for card: Card) -> String {
        if emoji[card] == nil, emojiChoises.count > 0 {
            emoji[card] = emojiChoises.remove(at: emojiChoises.count.arc4random)
            }
//        
//        if emoji[card.identifier] != nil {
//        return emoji[card.identifier]!
//        }else{
//        return "?"
//        }
//        - Equality code >>>>>-
        return emoji[card] ?? "?"
    }
    
    //MARK: Метка для установки названия темы
    @IBOutlet weak var titleLabel: UILabel!
    
    //MARK: Метка вывода количества переворотов карт
    @IBOutlet private weak var flipCountLabel: UILabel!
    
    //MARK: Кнопка начала новой игры
    @IBOutlet weak var newGameButton: UIButton!
    
    //MARK: Метка вывода счета игры
    @IBOutlet weak var scoreLabel: UILabel! 
    
    //MARK: Метод реализующий сброс всех счетчиков и загрузку рандомной темы
    //Начало новой игры
    @IBAction func newGame(_ sender: UIButton) {
        game.resetGame()
        indexTheme = emojiThemes.count.arc4random
        updateViewFromModel()
    }
    
    //MARK: Массив всех кнопок на экране
    @IBOutlet private var cardButtons: [UIButton]!
    
    //MARK: Метод касания карты
    //Счетчик увеличивается на единицу при каждом касании карты
    //Переменной cardNumber присваивается индекс нажатой кнопки
    //Конструкция if..else необходима для нормальной работы с опционалом из свойства индекса Int?
    //Если разместить "!" для принудительного изъятия ассоциированного значения опционала, получим аварийного завершение работы в случае nil
    @IBAction private func touchCard(_ sender: UIButton) {
        if let cardNumber = cardButtons.firstIndex(of: sender) {
                    //flipCard(withEmoji: emojiChoises[cardNumber], on: sender)
            game.chooseCard(at: cardNumber)
            updateViewFromModel()
        } else {
            print("choosen card was not in cardButtons")
        }
// flipCard(withEmoji: "👻", on: sender)
        
    }
    
 /*   @IBAction func touchSecondButton(_ sender: UIButton) {
        flipCount += 1
                flipCard(withEmoji: "🎃", on: sender)
    }*/
    
    /*func flipCard(withEmoji emoji: String, on button: UIButton) {
        if button.currentTitle == emoji {
            button.setTitle("", for: UIControl.State.normal)
            button.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        } else {
            button.setTitle(emoji, for: UIControl.State.normal)
            button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    } */
    
    
    //MARK: Метод обновления представления View согласно изменения в Модели, когда game изменится - на экране тоже должны происходить изменения
    //После вызова метода, идет быстрая пробежка через цикл по свойствам всех кнопок-карт
    //Проверяются карты текущей игры, а меняются свойства бекграунд-колора и тайтла КНОПОК
    private func updateViewFromModel() {
        for index in cardButtons.indices {
            let button = cardButtons[index]
            let card = game.cards[index]
            if card.isFaceUp {
                button.setTitle(emoji (for: card), for: UIControl.State.normal)
                button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                } else {
                button.setTitle("", for: UIControl.State.normal)
                button.backgroundColor = card.isMatched ? #colorLiteral(red: 0.9698604061, green: 0.2485079455, blue: 0.1116747309, alpha: 0) : cardBackColor
            }
        }
        scoreLabel.text = "Score: \(game.score)"
        flipCountLabel.text = "Flips: \(game.flipCount)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indexTheme = emojiThemes.count.arc4random
        updateViewFromModel()
    }
    
}

