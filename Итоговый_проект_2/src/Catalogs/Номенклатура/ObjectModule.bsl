
Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	
	//В модуле объекта переопределить событие ОбработкаЗаполнения, заполнив тип и ставку НДС значениями по умолчанию (Товар, НДС20). 
	//Заполнять только для элемента (для группы эти реквизиты не определены).
	
	Если Не ЭтоГруппа Тогда 
		ТипНоменклатуры = Перечисления.ТипыНоменклатуры.Товар;
		//
		СтавкаНДС = Перечисления.СтавкиНДС.НДС20;
	КонецЕсли;
	
КонецПроцедуры
