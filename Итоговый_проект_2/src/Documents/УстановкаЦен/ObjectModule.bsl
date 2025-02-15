
Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	Ответственный = ПараметрыСеанса.ТекущийСотрудник;
КонецПроцедуры


Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	//Переопределить событие ОбработкаПроведения, формируя движения по регистру сведений Цены датой документа
	Движения.Цены.Записывать = Истина;
	
	Для каждого ТекСтрокаЦены из Цены Цикл
		
		Движение = Движения.Цены.Добавить();
		Движение.Период = Дата;
		Движение.Номенклатура = ТекСтрокаЦены.Номенклатура;
		Движение.Цена = ТекСтрокаЦены.Цена;
		
	КонецЦикла;
	
КонецПроцедуры



