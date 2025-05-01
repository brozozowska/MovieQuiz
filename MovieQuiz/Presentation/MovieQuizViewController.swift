import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private let presenter = MovieQuizPresenter()
    private var alertPresenter: AlertPresenter?
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestionModel?
    private var correctAnswers = 0
    private let statisticService: StatisticServiceProtocol = StatisticService()
        
    // MARK: - Lifecycle
    // 1. Загружаем ViewController, показываем индикатор загрузки, создаём экземпляр QuestionFactory, инициализируем загрузку и делегата, создаём экземпляр alertPresenter и инициализируем делегата
    // В случае успеха загрузки запускаем методы didLoadDataFromServer() и didReceiveNextQuestion(question:), в случае ошибки загрузки — метод didFailToLoadData(with:)
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoadingIndicator()
        presenter.viewController = self
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        alertPresenter = AlertPresenter(delegate: self)
    }
    
    // MARK: - QuestionFactoryDelegate
    // 2. Скрываем индикатор загрузки, получаем вопрос, конвертируем его в QuizStepModel и запускаем метод show(step:)
    // Или запускаем методом showNetworkError(message:)
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestionModel?) {
        guard let question else { return }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
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
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
        
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        disableButtons()
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
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
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    // Изменение UI на основе QuizStepModel — показываем вопрос на экране
    private func show(step: QuizStepModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // Конвертируем полученные данные QuizResultsModel в AlertModel, обнуляем ответы пользователя и запускаем presentAlert(model:) с текстом результата
    private func show(result: QuizResultsModel) {
        alertPresenter?.showAlert(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self else { return }
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    // 4. Показываем результат ответа и переходим к методу showNextQuestionOrResult()
    func showAnswerResult(isCorrect: Bool) {
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
    
    // 5. Формируем данные для модели QuizResultsModel, обновляем статистику перед показом и запускаем метод show(result:) или запрашиваем следующий вопрос
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            let bestGame = statisticService.bestGame
            let totalAccuracy = String(format: "%.2f", statisticService.totalAccuracy)
            let title = "Этот раунд окончен!"
            let text = """
                Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                Средняя точность: \(totalAccuracy)%
                """
            let buttonText = "Сыграть ещё раз"
            show(result: QuizResultsModel(title: title, text: text, buttonText: buttonText))
        } else {
            presenter.switchToNextQuestion()
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    // Формируем текст ошибки, обнуляем ответы пользователя, пытаемся повторно загрузить данные и запускаем presentAlert(model:) с текстом ошибки
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let title = "Ошибка"
        let message = message
        let buttonText = "Попробовать ещё раз"
        alertPresenter?.showAlert(
            title: title,
            message: message,
            buttonText: buttonText,
        ) { [weak self] in
            guard let self else { return }
            presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.loadData()
        }
    }
}
