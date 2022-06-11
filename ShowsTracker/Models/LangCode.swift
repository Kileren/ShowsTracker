//
//  LangCode.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 29.05.2022.
//

import Foundation

enum LangCode: String, CaseIterable {
    case aa
    case ab
    case af
    case am
    case an
    case ar
    case `as`
    case ay
    case az
    case ba
    case be
    case bg
    case bh
    case bi
    case bn
    case bo
    case br
    case ca
    case co
    case cs
    case cy
    case da
    case de
    case dz
    case el
    case en
    case eo
    case es
    case et
    case eu
    case fa
    case fi
    case fj
    case fo
    case fr
    case fy
    case ga
    case gd
    case gl
    case gn
    case gu
    case gv
    case ha
    case he
    case hi
    case hr
    case ht
    case hu
    case hy
    case ia
    case id
    case ie
    case ii
    case ik
    case io
    case `is`
    case it
    case iu
    case ja
    case jv
    case ka
    case kk
    case kl
    case km
    case kn
    case ko
    case ks
    case ku
    case ky
    case la
    case li
    case ln
    case lo
    case lt
    case lv
    case mg
    case mi
    case mk
    case ml
    case mn
    case mo
    case mr
    case ms
    case mt
    case my
    case na
    case ne
    case nl
    case no
    case oc
    case om
    case or
    case pa
    case pl
    case ps
    case pt
    case qu
    case rm
    case rn
    case ro
    case ru
    case rw
    case sa
    case sd
    case sg
    case sh
    case si
    case sk
    case sl
    case sm
    case sn
    case so
    case sq
    case sr
    case ss
    case st
    case su
    case sv
    case sw
    case ta
    case te
    case tg
    case th
    case ti
    case tk
    case tl
    case tn
    case to
    case tr
    case ts
    case tt
    case tw
    case ug
    case uk
    case ur
    case uz
    case vi
    case vo
    case wa
    case wo
    case xh
    case yi
    case yo
    case zh
    case zu
    
    var nameRu: String {
        switch self {
        case .aa: return "Афарский"
        case .ab: return "Абхазский"
        case .af: return "Африкаанс"
        case .am: return "Амхарский"
        case .an: return "Арагонский"
        case .ar: return "Арабский"
        case .as: return "Ассамский"
        case .ay: return "Аймарский"
        case .az: return "Азербайджанский"
        case .ba: return "Башкирский"
        case .be: return "Белорусский"
        case .bg: return "Болгарский"
        case .bh: return "Бихарский"
        case .bi: return "Бислама"
        case .bn: return "Бенгальский"
        case .bo: return "Тибетский"
        case .br: return "Бретонский"
        case .ca: return "Каталонский"
        case .co: return "Корсиканский"
        case .cs: return "Чешский"
        case .cy: return "Валлийский (Уэльский)"
        case .da: return "Датский"
        case .de: return "Немецкий"
        case .dz: return "Бхутани"
        case .el: return "Греческий"
        case .en: return "Английский"
        case .eo: return "Эсперанто"
        case .es: return "Испанский"
        case .et: return "Эстонский"
        case .eu: return "Баскский"
        case .fa: return "Фарси"
        case .fi: return "Финский"
        case .fj: return "Фиджи"
        case .fo: return "Фарерский"
        case .fr: return "Французский"
        case .fy: return "Фризский"
        case .ga: return "Ирландский"
        case .gd: return "Гэльский (Шотландский)"
        case .gl: return "Галисийский"
        case .gn: return "Гуарани"
        case .gu: return "Гуджарати"
        case .gv: return "Гэльский (язык жителей острова Мэн)"
        case .ha: return "Хауса"
        case .he: return "Еврейский"
        case .hi: return "Хинди"
        case .hr: return "Хорватский"
        case .ht: return "Гаитянский Креольский"
        case .hu: return "Венгерский"
        case .hy: return "Армянский"
        case .ia: return "Интерлингва"
        case .id: return "Индонезийский"
        case .ie: return "Интерлингва"
        case .ii: return "Сычуань И"
        case .ik: return "Инупиак"
        case .io: return "Идо"
        case .is: return "Исландский"
        case .it: return "Итальянский"
        case .iu: return "Инуктитут"
        case .ja: return "Японский"
        case .jv: return "Яванский"
        case .ka: return "Грузинский"
        case .kk: return "Казахский"
        case .kl: return "Гренландский"
        case .km: return "Камбоджийский"
        case .kn: return "Каннада"
        case .ko: return "Корейский"
        case .ks: return "Кашмирский (Кашмири)"
        case .ku: return "Курдский"
        case .ky: return "Киргизский"
        case .la: return "Латинский"
        case .li: return "Лимбургский (Лимбургер)"
        case .ln: return "Лингала"
        case .lo: return "Лаосский"
        case .lt: return "Литовский"
        case .lv: return "Латвийский"
        case .mg: return "Малагасийский"
        case .mi: return "Маорийский"
        case .mk: return "Македонский"
        case .ml: return "Малаялам"
        case .mn: return "Монгольский"
        case .mo: return "Молдавский"
        case .mr: return "Маратхский"
        case .ms: return "Малайский"
        case .mt: return "Мальтийский"
        case .my: return "Бирманский"
        case .na: return "Науруанский"
        case .ne: return "Непальский"
        case .nl: return "Нидерландский"
        case .no: return "Норвежский"
        case .oc: return "Окситанский"
        case .om: return "Оромо (Афан, Галла)"
        case .or: return "Ория"
        case .pa: return "Пенджабский (Панджабский)"
        case .pl: return "Польский"
        case .ps: return "Пушту (Пушто)"
        case .pt: return "Португальский"
        case .qu: return "Кечуа"
        case .rm: return "Ретороманский"
        case .rn: return "Кирунди (Рунди)"
        case .ro: return "Румынский"
        case .ru: return "Русский"
        case .rw: return "Киняруанда (Руанда)"
        case .sa: return "Санскритский"
        case .sd: return "Синдхи"
        case .sg: return "Сангро"
        case .sh: return "Сербо-Хорватский"
        case .si: return "Сингальский (Сингалезский)"
        case .sk: return "Словацкий"
        case .sl: return "Словенский"
        case .sm: return "Самоанский"
        case .sn: return "Шона"
        case .so: return "Сомалийский"
        case .sq: return "Албанский"
        case .sr: return "Сербский"
        case .ss: return "Свати"
        case .st: return "Северный сото"
        case .su: return "Сунданский"
        case .sv: return "Шведский"
        case .sw: return "Суахили"
        case .ta: return "Тамильский"
        case .te: return "Телугу"
        case .tg: return "Таджикский"
        case .th: return "Тайский"
        case .ti: return "Тигринья"
        case .tk: return "Туркменский"
        case .tl: return "Тагальский"
        case .tn: return "Тсвана (Сетсвана)"
        case .to: return "Тонга (Тонганский)"
        case .tr: return "Турецкий"
        case .ts: return "Тсонга"
        case .tt: return "Татарский"
        case .tw: return "Чви (Тви)"
        case .ug: return "Уйгурский"
        case .uk: return "Украинский"
        case .ur: return "Урду"
        case .uz: return "Узбекский"
        case .vi: return "Вьетнамский"
        case .vo: return "Волапюк"
        case .wa: return "Валлон"
        case .wo: return "Волоф"
        case .xh: return "Коса"
        case .yi: return "Идиш"
        case .yo: return "Йоруба"
        case .zh: return "Китайский"
        case .zu: return "Зулусский"
        }
    }
}
