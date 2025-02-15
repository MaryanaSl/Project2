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

## Примеры кода из проекта

+ Документ Установка цен. 
 + Форма документа

![image](https://github.com/user-attachments/assets/517ef9fc-c1ce-4e36-845b-e98579583659)

+ Модуль формы:
   
   ```bsl


&НаКлиенте
Процедура ЦеныНоменклатураПриИзменении(Элемент)
	// Переопределить событие ПриИзменении поля ввода номенклатуры и 
	//вызвать в нем процедуру ПриИзмененииНоменклатуры с передачей текущих данных таблицы цен  
	
	ТекДанные = Элементы.Цены.ТекущиеДанные;
    ПриИзмененииНоменклатуры (ТекДанные);
	
КонецПроцедуры


&НаКлиенте
Процедура ПриИзмененииНоменклатуры (ИзмененнаяСтрока)
	//Создать клиентскую процедуру ПриИзмененииНоменклатуры с параметром ИзмененнаяСтрока 
	//(ДанныеФормыЭлементКоллекции), в которой, если Номенклатура заполнена, 
	//вызвать ЦеныВызовСервера.ЦенаНаДату и заполнить цену
	
	Если ЗначениеЗаполнено(ИзмененнаяСтрока.Номенклатура) Тогда
		ИзмененнаяСтрока.Цена = ЦеныВызовСервера.ЦенаНаДату(ИзмененнаяСтрока.Номенклатура, Объект.Дата);
	КонецЕсли;  
	
		
КонецПроцедуры

&НаКлиенте
Процедура Подбор(Команда)
	// Добавить команду Подбор, разместив ее в командной панели таблицы цен. 
	//В обработчике команды открыть форму выбора справочника Номенклатура 
	//с параметром ЗакрыватьПриВыборе = Ложь, указав в качестве владельца таблицу цен.

    ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ВыборГруппИЭлементов", ИспользованиеГруппИЭлементов.ГруппыИЭлементы);
	ПараметрыФормы.Вставить("ЗакрыватьПриВыборе", Ложь);
	ОткрытьФорму("Справочник.Номенклатура.ФормаВыбора", ПараметрыФормы, Элементы.Цены);

КонецПроцедуры

&НаКлиенте
Процедура ЦеныОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	//Переопределить событие ОбработкаВыбора таблицы цен. 
	//В обработчике отказаться от стандартной обработки и, 
	//если в таблице еще нет выбранного значения - добавить строку и 
	//вызвать процедуру ПриИзмененииНоменклатуры, передав добавленную строку.  
	СтандартнаяОбработка = Ложь;
	
	// Выполним поиск в таблице строки с этой номенклатурой;
	ОтборСтрок = Новый Структура ("Номенклатура", ВыбранноеЗначение);
	НайденныеСтрокиВСпискеВыбранных = Объект.Цены.НайтиСтроки(ОтборСтрок);
	
	
	//Если строка не найдена - создадим новую строку, в колонку 
	//Номенклатура укажем выбранное значение, 	
	Если НайденныеСтрокиВСпискеВыбранных.Количество() = 0 Тогда
		
		НоваяСтрокаТаблицы = Объект.Цены.Добавить();
		НоваяСтрокаТаблицы.Номенклатура = ВыбранноеЗначение;     
		ПриИзмененииНоменклатуры(НоваяСтрокаТаблицы);
		
	Иначе 
		Возврат;
	КонецЕсли;
	
КонецПроцедуры


   ```
