#import "lib.typ": *
#import "./common/glossary.typ": glossary-entries
#import "./common/acronym.typ": acronym-entries
#import "./common/symbols.typ": symbols-entries


// Делаем вот так, и голова не болит
// Хотя зачем нам в принципе эта фигня там -- вопрос хороший
#let back-refs-on-right(entry) = {
  return text()[#h(1fr) #get-entry-back-references(entry).join(",")]
}


#show: template.with(
  glossary-list: symbols-entries,
)

#register-glossary(symbols-entries)
#register-glossary(acronym-entries)
#register-glossary(glossary-entries)


#include "./parts/intro.typ"
#show heading.where(level: 1): set heading(numbering: "Глава 1. ") // и здесь мы как раз начинаем главы, чтобы не сводить с ума список глав (он хочет содержание и введение тоже засчитать за главу)
#include "./parts/part1.typ"
#include "./parts/part2.typ"

// Всё, хватит с нас чиселок
#show heading: set heading(numbering: none)

= Список сокращений и условных обозначений
#print-glossary(acronym-entries+symbols-entries, user-print-back-references: back-refs-on-right)

#bibliography(title: upper("Список литературы"), "common/external.bib", style: "gost-r-705-2008-numeric")

// Только если есть реальные термины..
// = Словарь терминов
// #print-glossary(glossary-entries, user-print-back-references: back-refs-on-right)



#include "./parts/appendix.typ"