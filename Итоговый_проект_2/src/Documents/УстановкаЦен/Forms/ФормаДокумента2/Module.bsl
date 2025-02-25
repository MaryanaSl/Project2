
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
