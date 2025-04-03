import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    // MARK: - Private Properties
    private let questionsAmount = 10
    private var alertPresenter: AlertPresenter?
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestionIndex = 0
    private var currentQuestion: QuizQuestionModel?
    private var correctAnswers = 0
        
    // MARK: - Lifecycle
    // 1. Загружаем ViewController, создаём экземпляр фабрики вопросов и запрашиваем первый вопрос, создаём экземпляр alertPresenter
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        alertPresenter = AlertPresenter(delegate: self)
    }
    
    // MARK: - QuestionFactoryDelegate
    // 2. Получаем вопрос, конвертируем его в QuizStepModel и запускаем метод show(step:)
    func didReceiveNextQuestion(question: QuizQuestionModel?) {
        guard let question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(step: viewModel)
        }
    }
    
    // MARK: - AlertPresenterDelegate
    // 6. Отображаем алерт с кнопкой на основе созданного экземпляра alertModel и запускаем действие completion при нажатии
    func presentAlert(model: AlertModel) {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - IB Actions
    // 3. Проверяем нажатие кнопок и переходим к методу showAnswerResult()
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        disableButtons()
        guard let currentQuestion else { return }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
    }
        
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        disableButtons()
        guard let currentQuestion else { return }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }
    
    // MARK: - Private Methods
    private func disableButtons() {
        yesButton.isUserInteractionEnabled = false
        noButton.isUserInteractionEnabled = false
    }

    private func enableButtons() {
        yesButton.isUserInteractionEnabled = true
        noButton.isUserInteractionEnabled = true
    }
    
    // Конвертер QuizQuestionModel в QuizStepModel
    private func convert(model: QuizQuestionModel) -> QuizStepModel {
        let image = UIImage(named: model.image) ?? UIImage()
        let question = model.text
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionsAmount)"
        return QuizStepModel(image: image, question: question, questionNumber: questionNumber)
    }
    
    // Изменение UI на основе QuizStepModel
    private func show(step: QuizStepModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // Конвертер QuizResultsModel в AlertModel и запуск presenterAlert() внутри делегата
    private func show(result: QuizResultsModel) {
        alertPresenter?.showAlert(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    // 4. Показываем результат и переходим к методу showNextQuestionOrResult()
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        if isCorrect {
            correctAnswers += 1
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.showNextQuestionOrResults()
            self.imageView.layer.borderWidth = 0
            self.enableButtons()
        }
    }
    
    // 5. Формируем данные для модели QuizResultsModel и запускаем метод show(result:) или запрашиваем следующий вопрос
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let title = "Этот раунд окончен!"
            let text = "Ваш результат: \(correctAnswers)/10"
            let buttonText = "Сыграть ещё раз"
            show(result: QuizResultsModel(title: title, text: text, buttonText: buttonText))
        } else {
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
        }
    }
}
