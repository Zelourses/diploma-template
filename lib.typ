#import "@preview/codly:1.3.0": *
#import "@preview/glossarium:0.5.4": *
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": codly-languages
#import "@preview/outrageous:0.4.0"


#let template(
  font-type: "Times New Roman",
  font-size: 14pt,
  link-color: black,
  glossary-list: [],
  body,
) = {
  set text(
    font: font-type,
    lang: "ru",
    size: font-size,
    fallback: true,
    hyphenate: false,
  )

  set page(
    margin: (top: 2cm, bottom: 2cm, left: 2.5cm, right: 1cm) // размер полей (ГОСТ 7.0.11-2011, 5.3.7)
  )

  set par(
    justify: true,
    linebreaks: "optimized",
    // Удивительно, но в типографской штуке каждый элемент считался параграфом
    // И это вызвало проблемы, быть не может!
    // @see: https://github.com/typst/typst/pull/5768
    first-line-indent: (amount: 2.5em, all: true), // Абзацный отступ. Должен быть одинаковым по всему тексту и равен пяти знакам (ГОСТ Р 7.0.11-2011, 5.3.7).
    leading: 1em // Полуторный интервал (ГОСТ 7.0.11-2011, 5.3.6)
  )

  set heading(numbering: "1.", outlined: true, supplement: [Раздел])
  show heading: it => {
    set align(center)
    set text(
      font: font-type,
      size: font-size,
    )
    set block(above: 3em, below: 3em) // Заголовки отделяют от текста сверху и снизу тремя интервалами (ГОСТ Р 7.0.11-2011, 5.3.5)

    if it.level == 1 {
      // Без weak получается пустая страница из ниоткуда
      pagebreak(weak: true) // новая страница для разделов 1 уровня 
      counter(figure).update(0) // сброс значения счетчика рисунков 
      counter(math.equation).update(0) // сброс значения счетчика уравнений 
      // Чтобы первый уровень был кричащим
      upper(it)
    } else {
      it
    }
    

  }

  // Не отображать ссылки на figure
  set ref(supplement: it => {
    if it.func() == figure {}
  })

  // настройка codly для кода
  show: codly-init.with()
  codly(languages: codly-languages, display-icon: false)


  // глоссарий, чтобы было хорошо
  show: make-glossary
  show link: set text(fill: link-color)

  //TODO: Нумерация уравнений

  // Рисунки
  show figure: align.with(center)
  set figure(supplement: [Рисунок])
  set figure.caption(separator: [ -- ])
  set figure(numbering: num => 
    ((counter(heading.where(level:1)).get() + (num,)).map(str).join(".")),)

  // TODO: настройка таблиц

  // Списки
  set enum(indent: 2.5em)

  state("section").update("body")


  // Нумерация уравнений 
  let eq_number(it) = {
    let part_number = counter(heading.where(level:1)).get()
    part_number 

    it
  }
  set math.equation(numbering: num => 
    ("("+(counter(heading.where(level:1)).get() + (num,)).map(str).join(".")+")"),
    supplement: [Уравнение],)


  // сквозная нумерация
  set page(
    numbering: "1", // сквозная нумерация
    number-align: center + bottom, // Не уверен что правильно, но что нет
  )
  counter(page).update(1)

  // Содержание
  // Здесь делается некоторая магия, чтобы заставить первый уровень иметь обводку "bold" и не ставить никаких точечек
  // У меня почему-то ехал alignment, если я делал это штатными средствами
  show outline.entry: outrageous.show-entry.with(
    ..outrageous.presets.typst, 
    font-weight: ("bold", auto),
    fill: (none, auto)
    )
  outline(title: upper("Содержание"), indent: 1.5em, depth: 3)

  body
}

#let appendix(body) = {

  counter(heading).update(0)
  
  // headings using letters
  show heading.where(level: 1): set heading(numbering: "Приложение A. ", supplement: [Приложение])
  show heading.where(level: 2): set heading(numbering: "A.1 ", supplement: [Приложение])

  set figure(numbering: (x) => context {
    let idx = numbering("A", counter(heading).at(here()).first())
    [#idx.#numbering("1",x)]
  })

  // Чтобы всё считалось в аппендиксе локально
  show heading: it => {
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: math.equation)).update(0)
    counter(figure.where(kind: raw)).update(0)

    it
  }

  body
  
}

#let icon(image) = {
  box(
    height: .8em,
    baseline: 0.05em,
    image
  )
  h(0.1em)
}