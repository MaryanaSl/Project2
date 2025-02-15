
Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	Ответственный = ПараметрыСеанса.ТекущийСотрудник;
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения) 
	СуммаДокумента = ТоварыИУслуги.Итог("Сумма"); 
	//товары - название табл.части, итог - команда. "Сумма" - название колонки
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	//формировать движения, выбрав предварительно запросом данные табличной части документа 
	//с типами номенклатуры и соединив с виртуальной таблицей Остатки регистра Товары по номенклатуре:  
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	РеализацияТоваровИУслугТоварыИУслуги.Номенклатура.ТипНоменклатуры КАК НоменклатураТипНоменклатуры,
	               |	РеализацияТоваровИУслугТоварыИУслуги.Номенклатура КАК Номенклатура,
	               |	СУММА(РеализацияТоваровИУслугТоварыИУслуги.Количество) КАК Количество,
	               |	СУММА(РеализацияТоваровИУслугТоварыИУслуги.Сумма) КАК Сумма
	               |ПОМЕСТИТЬ ВТ_ДанныеДокумента
	               |ИЗ
	               |	Документ.РеализацияТоваровИУслуг.ТоварыИУслуги КАК РеализацияТоваровИУслугТоварыИУслуги
	               |ГДЕ
	               |	РеализацияТоваровИУслугТоварыИУслуги.Ссылка = &Ссылка
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	РеализацияТоваровИУслугТоварыИУслуги.Номенклатура.ТипНоменклатуры,
	               |	РеализацияТоваровИУслугТоварыИУслуги.Номенклатура
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ВТ_ДанныеДокумента.НоменклатураТипНоменклатуры КАК НоменклатураТипНоменклатуры,
	               |	ВТ_ДанныеДокумента.Номенклатура КАК Номенклатура,
	               |	ВТ_ДанныеДокумента.Количество КАК Количество,
	               |	ВТ_ДанныеДокумента.Сумма КАК Сумма,
	               |	ЕСТЬNULL(ТоварыОстатки.КоличествоОстаток, 0) КАК КоличествоОстаток,
	               |	ЕСТЬNULL(ТоварыОстатки.СуммаОстаток, 0) КАК СуммаОстаток
	               |ИЗ
	               |	ВТ_ДанныеДокумента КАК ВТ_ДанныеДокумента
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.Товары.Остатки(
	               |				&Период,
	               |				Номенклатура В
	               |					(ВЫБРАТЬ
	               |						ВТ_ДанныеДокумента.Номенклатура КАК Номенклатура
	               |					ИЗ
	               |						ВТ_ДанныеДокумента КАК ВТ_ДанныеДокумента)) КАК ТоварыОстатки
	               |		ПО ВТ_ДанныеДокумента.Номенклатура = ТоварыОстатки.Номенклатура";
	
	Запрос.УстановитьПараметр("Ссылка", ЭтотОбъект.Ссылка);
	//установим параметр Период - прямо до проведения документа 
	Запрос.УстановитьПараметр("Период", Новый Граница (МоментВремени(), ВидГраницы.Исключая));
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	//По регистру ВзаиморасчетыСКонтрагентами - 
	//одно движение вида "Приход" с указанием контрагента-покупателя и общей суммы
	
	Движения.ВзаиморасчетыСКонтрагентами.Очистить();
	Движения.ВзаиморасчетыСКонтрагентами.Записывать = Истина;
	
	
	Движение = Движения.ВзаиморасчетыСКонтрагентами.Добавить();
	Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
	Движение.Период = Дата;
	Движение.Контрагент = Покупатель;
	Движение.Сумма = СуммаДокумента;
	
	//По регистру Товары - движения вида "Расход" по каждой строке с номенклатурой 
	//типа Товары с указанием номенклатуры, количества и суммы. 
	//Сумму рассчитывать, определив среднюю стоимость единицы делением суммы 
	//остатка на количество остатка и умножив среднюю стоимость на реализуемое количество. 
	//При нехватке остатков отказываться от проведения, выводя пользователю разумное сообщение. 
	
	Движения.Товары.Очистить();
	Движения.Товары.Записывать = Истина;
	
	Движения.Доходы.Очистить();
	Движения.Доходы.Записывать = Истина;  
	
	Движения.Расходы.Очистить();
	Движения.Расходы.Записывать = Истина;
	
	//По регистру Доходы - движения по каждой строке с указанием номенклатуры, количества и суммы
	Пока Выборка.Следующий() Цикл 
		Движение = Движения.Доходы.Добавить();
		Движение.Период = Дата;
		Движение.Номенклатура = Выборка.Номенклатура;
		Движение.Количество = Выборка.Количество;
		Движение.Сумма = Выборка.Сумма;
		
		Если Выборка.НоменклатураТипНоменклатуры <> Перечисления.ТипыНоменклатуры.Товар Тогда
			Продолжить;
		КонецЕсли;
		
		//проверяем, хватает ли остатка товара
		Если Выборка.Количество > Выборка.КоличествоОстаток Тогда
			//сообщаем что товара не хватате
			Сообщить (СтрШаблон("Не хватает товара %1", Выборка.Номенклатура));
			Отказ = Истина;
			//прекращаем выполнение этой итерации цикла
			Продолжить;
		КонецЕсли;
		
		//необходмо рассчитать себестоимось    
		//Если кол-во остаток = кол-ву в документе, т.е. списываем все в 0, то СС = Сумма Остаток
		Если Выборка.Количество = Выборка.КоличествоОстаток Тогда 
			Себестоимость = Выборка.СуммаОстаток;
		ИНаче
			Себестоимость = Выборка.СуммаОстаток * Выборка.Количество/Выборка.КоличествоОстаток;
		КонецЕсли;
		
		//формируем движения в регистре Товары
		Движение = Движения.Товары.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата;
		Движение.Номенклатура = Выборка.Номенклатура;
		Движение.Количество = Выборка.Количество; 
		Движение.Сумма = Себестоимость;
		
		//По регистру Расходы - движения по каждой строке с номенклатурой типа Товары 
		//с указанием номенклатуры и суммы, равной сумме расхода по регистру Товары.
		Движение = Движения.Расходы.Добавить();
		Движение.Период = Дата;
		Движение.Номенклатура = Выборка.Номенклатура;
		Движение.Сумма = Себестоимость;
		
	КонецЦикла;
	
КонецПроцедуры


