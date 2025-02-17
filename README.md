# Диплом блока Б "Сделки и деньги"

## Описание задачи

Развить созданную в блоке А конфигурацию "Управление ИТ-фирмой", обеспечив возможность учета хозяйственных операций по приобретению и реализации товаров и услуг и движению денежных средств с базовым механизмом ценообразования и набором простых отчетов.
В конфигурацию добавлются:
+ перечисления, 
+ справочники, 
+ документ с формой подбора номенклатуры и атоматическим назначением цен согласно срезу последних регистра сведений Цены, и формирующий движения по регистру сведений
+ документ с формой выбора номенклатуры и ном.групп с автоматическим назначений скидок согласно срезу последний регистра, и формирующий движения по регистру сведений
+ журналы документов
+ документы с формой, в которой реализован выбор и подбор номенклатуры с автоматическим пересчетом числовых колонок Цена, Сумма, Сумма НДС, формирующий дивжения по регистрам накопления с контролем остатков
+ регистры сведений
+ регистры накоплений
+ отчет доходы и расходы, который выводит, соединяя, данные регистров Доходы и Расходы в три колонки ("Доходы", "Расходы", "Прибыль")
+ отчет движения товаров, который выводит данные регистра Товары: остатки и обороты по количеству и сумме
+ отчет Взаиморасчеты с контрагентами, который выводит данные регистра ВзаиморасчетыСКонтрагентами: остатки и обороты

Итогом станет конфигурация, содержащая главные элементы управленческих учетных систем на платформе 1С:Предприятие.

Подробные требовния к результату [тут](https://github.com/MaryanaSl/Project2/blob/main/%D1%82%D1%80%D0%B5%D0%B1%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D1%8F.md)

## Реализованное решение

* Во все создаваемые документы добавляю реквизит Ответственный (СправочникСсылка.Сотрудники). В модулях объектов переопределяю событие ОбработкаЗаполнения, заполняя реквизит Ответственный сотрудником текущего пользователя.
* В формах документов, на закладке "Командный интерфейс", включаю видимость команд перехода к движениям по соответствующим регистрам, чтобы они появились в панели навигации: это сильно упростит отладку и проверку.
* Все добавляемые объекты, за исключением регистров и документов, управляющих ценами и скидками, включаю в роль "Базовые права", разрешая все действия, кроме интерактивного удаления. Запрещаю интерактивное удаление и в роли "Полные права".

[Подсистема "Настройка"](https://github.com/MaryanaSl/Project2/blob/main/%D0%9D%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B9%D0%BA%D0%B0.md)

Номенклатура, цены, скидки.

[Подсистема "Сделки"](https://github.com/MaryanaSl/Project2/blob/main/%D0%A1%D0%B4%D0%B5%D0%BB%D0%BA%D0%B8.md)

Поступление и реализация товаров и услуг.

[Подсистема "Деньги"](https://github.com/MaryanaSl/Project2/blob/main/%D0%94%D0%B5%D0%BD%D1%8C%D0%B3%D0%B8.md)

Поступление и списание денежных средств.

[Отчеты](https://github.com/MaryanaSl/Project2/blob/main/%D0%9E%D1%82%D1%87%D0%B5%D1%82%D1%8B.md)

Отчеты по взаиморасчетам, движению товаров, доходам и расходам.

