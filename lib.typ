//--------------------------------------------------------------------------------------------------
//
// Стиль данной работы основан на требовании к выпускным квалификационным работам
// от 2022 года ИТМО, версия 4.0 -- https://student.itmo.ru/files/1314
// Некоторые предпочтения, которые были выбраны
// - Нумерация иллюстраций не сквозные, а имеют номер главы + её внутренний номер
// - Стиль содержания выбран самый "стандартный", можно изменить его иначе
// - Отступы взяты чуть "консервативно", отступ справа можно сделать не 1.5см а 1см
// - Если в заголовках в конце стоит точка, будет паника с сообщением
//
//--------------------------------------------------------------------------------------------------
#import "@preview/codly:1.3.0": *
#import "@preview/glossarium:0.5.4": *
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": codly-languages
#import "@preview/outrageous:0.4.0"

#let to-string(it) = {
  if type(it) == str {
    it
  } else if type(it) != content {
    str(it)
  } else if it.has("text") {
    it.text
  } else if it.has("children") {
    it.children.map(to-string).join()
  } else if it.has("body") {
    to-string(it.body)
  } else if it == [ ] {
    " "
  }
}


#let template(
  font-type: "Times New Roman", // Прям официально, должен быть он (пункт 4.2)
  font-size: 14pt, // Минимально 12, рекомендуемо 14
  link-color: black,
  start_number: 4, // Обычно начинается с четвёртой страницы
  // Список заголовков, которые необходимо отцентрировать и не применять никакой страшной магии
  // Для их "улучшения"
  // Список взят из пункта 4.4.1
  important_headings: (
    "содержание",
    "введение",
    "заключение",
    "приложение",
    "список использованных источников",
    "список сокращений и условных обозначений",
    "термины и определения",
  ),
  body,
) = {
  set text(
    font: font-type,
    lang: "ru",
    size: font-size,
    fallback: true,
    // hyphenate: true,
  )

  set page(
    margin: (top: 2cm, bottom: 2cm, left: 3cm, right: 1.5cm), // размер полей (пункт 4.2)
  )

  set par(
    justify: true,
    linebreaks: "optimized",
    // Удивительно, но в типографской штуке каждый элемент считался параграфом
    // И это вызвало проблемы, быть не может!
    // @see: https://github.com/typst/typst/pull/5768
    first-line-indent: (amount: 1.25cm, all: true), // Абзацный отступ равен 1.25, везде одинаков (пункт 4.2)
    leading: 1em, // Полуторный интервал (пункт 4.2)
  )

  // Этот небольшой кусочек кода нужен чтобы не делать точку в конце номера заголовка
  set heading(numbering: (..nums) => nums.pos().map(str).join("."), outlined: true, supplement: [Раздел])
  show heading: it => {
    if to-string(it.body).ends-with(".") {
      panic("Согласно пункту 4.4.4 заголовки должны быть без точки в конце", to-string(it.body))
    }

    set text(
      font: font-type,
      size: font-size,
    )
    set block(
      above: 3em,
      below: 3em,
    ) // Заголовки отделяют от текста сверху и снизу тремя интервалами (ГОСТ Р 7.0.11-2011, 5.3.5)

    if it.level == 1 {
      // Без weak получается пустая страница из ниоткуда
      pagebreak(weak: true) // новая страница для разделов 1 уровня
      counter(figure).update(0) // сброс значения счётчика.. фигур?
      counter(figure.where(kind: image)).update(0) // сброс счётчика рисунков
      counter(math.equation).update(0) // сброс значения счетчика уравнений
      // Если надо, здесь пишется upper(it), и получаем кричащий первый уровень
      if important_headings.contains(lower(to-string(it.body))) {
        align(center, it)
      } else {
        it
      }
    } else {
      it
    }
  }

  // Не отображать ссылки на figure
  set ref(
    supplement: it => {
      if it.func() == figure { }
    },
  )

  // настройка codly для кода
  show: codly-init.with()
  codly(languages: codly-languages, display-icon: false)


  // глоссарий, чтобы было хорошо
  show: make-glossary
  show link: set text(fill: link-color)


  // Рисунки
  show figure: align.with(center)
  set figure(supplement: [Рисунок])
  set figure.caption(separator: [ -- ])
  set figure(numbering: num => ((counter(heading.where(level: 1)).get() + (num,)).map(str).join(".")))

  // TODO: настройка таблиц

  // Списки
  set enum(indent: 2.5em)
  set list(indent: 2.5em)

  state("section").update("body")


  // Нумерация уравнений
  let eq_number(it) = {
    let part_number = counter(heading.where(level: 1)).get()
    part_number

    it
  }
  set math.equation(
    numbering: num => ("(" + (counter(heading.where(level: 1)).get() + (num,)).map(str).join(".") + ")"),
    supplement: [Уравнение],
  )


  // сквозная нумерация
  set page(
    numbering: "1", // сквозная нумерация
    number-align: center + bottom, // Номер страницы по-середине и снизу
  )
  counter(page).update(start_number)

  // Содержание
  // Здесь делается некоторая магия, чтобы заставить первый уровень иметь обводку "bold" и не ставить никаких точечек
  // У меня почему-то ехал alignment, если я делал это штатными средствами
  show outline.entry: outrageous.show-entry.with(
    ..outrageous.presets.typst,
    font-weight: ("bold", auto),
    fill: (none, auto),
  )
  // Правило для того чтобы каждый заголовок первого уровня был довольно "далеко" и выделялся
  show outline.entry: it => {
    if (it.level == 1) {
      v(8.5pt)
      upper(it) // Необходимо согласно (4.4.1)
    } else {
      it
    }
  }


  outline(title: upper("Содержание"), indent: 1.5em, depth: 30)

  body
}

#let appendix(body) = {
  counter(heading).update(0)

  // headings using letters
  show heading.where(level: 1): set heading(numbering: "Приложение A ", supplement: [Приложение])
  show heading.where(level: 2): set heading(numbering: "A.1 ", supplement: [Приложение])

  set figure(
    numbering: x => context {
      let idx = numbering("A", counter(heading).at(here()).first())
      [#idx.#numbering("1", x)]
    },
  )

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
    image,
  )
  h(0.1em)
}

#let note(body) = highlight(body, stroke: fuchsia)
