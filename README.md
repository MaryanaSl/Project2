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

1. Документ Установка цен - необходимо реализовать подбор номенклатуры и автоматически проставляются актуальные цены. 
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
  + ОМ ЦеныВызовСервера (вызывается в процедуре ПриИзмененииНоменклатуры с целью заполнения актуальной ценой
```bsl
Функция ЦенаНаДату (Номенклатура, Дата) Экспорт
	
	Возврат ЦеныСервер.ЦенаНаДату(Номенклатура, Дата);
	
КонецФункции
   ```
+ ОМ ЦеныСервер
```bsl
Функция ЦенаНаДату (Номенклатура, Дата) Экспорт
	
	//получить запросом срез последних на указанную дату с отбором по номенклатуре и вернет цену. 
	Запрос = Новый Запрос;
	Запрос.Текст = 
			"   ВЫБРАТЬ
			|	ЦеныСрезПоследних.Номенклатура КАК Номенклатура,
			|	МАКСИМУМ(ЦеныСрезПоследних.Период) КАК Период
			|ПОМЕСТИТЬ ВТ_номенклатурыБезЦены
			|ИЗ
			|	РегистрСведений.Цены.СрезПоследних (КОНЕЦПЕРИОДА(&Период, ДЕНЬ), ) КАК ЦеныСрезПоследних
			|ГДЕ
			|	ЦеныСрезПоследних.Номенклатура = &Номенклатура
			|
			|СГРУППИРОВАТЬ ПО
			|	ЦеныСрезПоследних.Номенклатура
			|;
			|
			|////////////////////////////////////////////////////////////////////////////////
			|ВЫБРАТЬ
			|	МАКСИМУМ(ЦеныСрезПоследних.Цена) КАК Цена,
			|	МАКСИМУМ(ЦеныСрезПоследних.Период) КАК Период,
			|	ЦеныСрезПоследних.Номенклатура КАК Номенклатура
			|ИЗ
			|	ВТ_номенклатурыБезЦены КАК ВТ_номенклатурыБезЦены
			|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.Цены.СрезПоследних КАК ЦеныСрезПоследних
			|		ПО ВТ_номенклатурыБезЦены.Номенклатура = ЦеныСрезПоследних.Номенклатура
			|			И ВТ_номенклатурыБезЦены.Период = ЦеныСрезПоследних.Период
			|
			|СГРУППИРОВАТЬ ПО
			|	ЦеныСрезПоследних.Номенклатура";

	Запрос.УстановитьПараметр("Период", Дата);
	Запрос.УстановитьПараметр("Номенклатура", Номенклатура);
	
	Выборка = Запрос.Выполнить().Выбрать(); 
	
	Пока Выборка.Следующий() Цикл
		Цена = Выборка.Цена;
	КонецЦикла;
	
	Возврат Цена;
	
КонецФункции
```


 + В резульате в документе Установка цен реализован подбор номенклатуры и автоматически проставляются актуальные цены:

  ![image](https://github.com/user-attachments/assets/0fcd63c4-85cc-48ad-a6c2-714ae045c8d2)

2. Документ Установка скидок - необходимо реализовать подбор номенклатуры или номенклатурной группы и устанавливать скидку. Если на конкретную номенклутру не заведена скидка, то получать скидку, установленную на ном.группу.

   + Форма документа
![image](https://github.com/user-attachments/assets/b852e70f-cd08-4dc6-96b8-59dd10935c66)

  + Модуль формы

```bsl
 &НаКлиенте
Процедура ПриИзмененииНоменклатурыНоменклатурнойГруппы (ИзмененнаяСтрока)
	//	Создать клиентскую процедуру ПриИзмененииНоменклатурыНоменклатурнойГруппы 
	//с параметром ИзмененнаяСтрока (ДанныеФормыЭлементКоллекции), 
	//в которой, если НоменклатураНоменклатурнаяГруппа заполнена, 
	//вызвать ЦеныВызовСервера.СкидкаНаДату и заполнить скидку.
	
	Если ЗначениеЗаполнено(ИзмененнаяСтрока.НоменклатураНоменклатурнаяГруппа) Тогда
		ИзмененнаяСтрока.Скидка = ЦеныВызовСервера.СкидкаНаДату(ИзмененнаяСтрока.НоменклатураНоменклатурнаяГруппа, Объект.Дата);
	КонецЕсли;  
		
КонецПроцедуры


&НаКлиенте
Процедура СкидкиНоменклатураНоменклатурнаяГруппаПриИзменении(Элемент)
	//Переопределить событие ПриИзменении поля ввода номенклатуры / номенклатурной группы 
	//и вызвать в нем процедуру ПриИзмененииНоменклатурыНоменклатурнойГруппы 
	//с передачей текущих данных таблицы скидок.     
	
	ТекДанные = Элементы.Скидки.ТекущиеДанные;
	ПриИзмененииНоменклатурыНоменклатурнойГруппы (ТекДанные);
	
КонецПроцедуры
```
  + ОМ ЦеныВызовСервера (вызывается в процедуре ПриИзмененииНоменклатурыНоменклатурнойГруппы с целью заполнения актуальной скидкой
```bsl
Функция СкидкаНаДату (Номенклатура, Дата) Экспорт
	//В общий модуль ЦеныВызовСервера добавить одноименную функцию-обертку
	Возврат ЦеныСервер.СкидкаНаДату(Номенклатура, Дата);
	
КонецФункции
   ```
+ ОМ ЦеныСервер
```bsl
Функция СкидкаНаДату (Номенклатура, Дата) Экспорт
	
	//получить запросом срез последних на указанную дату с отбором по номенклатуре 
	//и номенклатурной группе и вернет скидку, установленную для номенклатурной группы, 
	//если нет скидки для конкретной номенклатуры.   
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
			"ВЫБРАТЬ
			|	СкидкиСрезПоследних.НоменклатураНоменклатурнаяГруппа.Ссылка КАК НоменклатураНоменклатурнаяГруппа,
			|	СкидкиСрезПоследних.Скидка КАК Скидка,
			|	0 КАК Приоритет
			|ПОМЕСТИТЬ ВременнаяТаблица_Скидки
			|ИЗ
			|	РегистрСведений.Скидки.СрезПоследних(КОНЕЦПЕРИОДА(&Период, ДЕНЬ), НоменклатураНоменклатурнаяГруппа = &Номенклатура) КАК СкидкиСрезПоследних
			|
			|ОБЪЕДИНИТЬ
			|
			|ВЫБРАТЬ
			|	СкидкиСрезПоследних.НоменклатураНоменклатурнаяГруппа.НоменклатурнаяГруппа,
			|	СкидкиСрезПоследних.Скидка,
			|	1
			|ИЗ
			|	РегистрСведений.Скидки.СрезПоследних(КОНЕЦПЕРИОДА(&Период, ДЕНЬ), НоменклатураНоменклатурнаяГруппа = &НоменклатурнаяГруппа) КАК СкидкиСрезПоследних
			|;
			|
			|////////////////////////////////////////////////////////////////////////////////
			|ВЫБРАТЬ ПЕРВЫЕ 1
			|	ВременнаяТаблица_Скидки.НоменклатураНоменклатурнаяГруппа.Ссылка КАК НоменклатураНоменклатурнаяГруппаСсылка,
			|	ВременнаяТаблица_Скидки.Скидка КАК Скидка,
			|	ВременнаяТаблица_Скидки.Приоритет КАК Приоритет
			|ИЗ
			|	ВременнаяТаблица_Скидки КАК ВременнаяТаблица_Скидки
			|
			|УПОРЯДОЧИТЬ ПО
			|	Приоритет ВОЗР";

	Запрос.УстановитьПараметр("Период", Дата);
	Запрос.УстановитьПараметр("Номенклатура", Номенклатура);
	Если ТипЗнч(Номенклатура) <> Тип("СправочникСсылка.НоменклатурныеГруппы") Тогда
		Запрос.УстановитьПараметр("НоменклатурнаяГруппа", Номенклатура.НоменклатурнаяГруппа);
	Иначе
		Запрос.УстановитьПараметр("НоменклатурнаяГруппа", Номенклатура);
	КонецЕсли;
	
	Выборка = Запрос.Выполнить().Выбрать(); 
	
	Пока Выборка.Следующий() Цикл
		Скидка = Выборка.Скидка;
	КонецЦикла;
	
	Возврат Скидка;
	
КонецФункции

```
 + В резульате в документе Установка скидки реализован подбор номенклатуры и ном.группы и автоматически проставляются актуальные скидки.  Если на конкретную номенклутру не заведена скидка, то ставится скидка, установленную на ном.группу.

![image](https://github.com/user-attachments/assets/b7c754cf-2c67-45ad-bbb0-1e3475c1eb59)

3. Документ Реализация товаров и услуг - в форме документа заполнять цену и скидку аналогично документам УстановкаЦен и УстановкаСкидок, при изменении количества, цены и скидки пересчитывается сумма и сумма НДС, а при изменении суммы и ставки НДС - сумма НДС. При нехватке остатков отказываться от проведения, выводя пользователю разумное сообщение.

+ модуль формы документа

  ```bsl


//Скидки определяются по срезу последних регистра сведений Скидки. 
//Если скидка установлена и на конкретный элемент справочника Номенклатура, 
//и на номенклатурную группу, приоритет имеет скидка для конкретного элемента.

//Цена определяется по данным регистра сведений Цены и не пересчитывается 
//при изменении скидки. Сумма определяется по цене с учетом скидки как: 
//Сумма = Количество * Цена * (100 - Скидка) / 100 
//При изменении суммы изменяется скидка, но не цена, по обратной формуле: 
//Скидка = 100 * (1 - Сумма / Количество / Цена)     


&НаКлиенте
Функция СуммаПоСтроке(Строка)
	// возвращает сумму с учетом количества, цены и скидки 
	Строка.Сумма = Строка.Количество * Строка.Цена * (100 - Строка.Скидка) / 100;
	Возврат Строка.Сумма;  
	
КонецФункции


&НаКлиенте
Процедура ПриИзмененииНоменклатуры(ИзмененнаяСтрока)
	// Заполнять цену и скидку аналогично документам 
	//УстановкаЦен и УстановкаСкидок, а также заполнять ставку НДС 
	//и вызывать процедуры ПриИзмененииЦены, ПриИзмененииСкидки и ПриИзмененииСтавкиНДС  
	
	ЗаполнитьЦенуИСкидку (ИзмененнаяСтрока);
	ИзмененнаяСтрока.СтавкаНДС = ПредопределенноеЗначение("Перечисление.СтавкиНДС.НДС20");
	
	ПриИзмененииЦены(ИзмененнаяСтрока); 
	ПриИзмененииСкидки(ИзмененнаяСтрока);
	ПриИзмененииСтавкиНДС(ИзмененнаяСтрока);
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьЦенуИСкидку (ИзмененнаяСтрока)
	 
	//вызвать ЦеныВызовСервера.ЦенаНаДату и заполнить цену
	
	Если ЗначениеЗаполнено(ИзмененнаяСтрока.Номенклатура) Тогда
		ИзмененнаяСтрока.Цена = ЦеныВызовСервера.ЦенаНаДату(ИзмененнаяСтрока.Номенклатура, Объект.Дата); 
		ИзмененнаяСтрока.Скидка = ЦеныВызовСервера.СкидкаНаДату(ИзмененнаяСтрока.Номенклатура, Объект.Дата);
	КонецЕсли;  
		
КонецПроцедуры


&НаКлиенте
Процедура ПриИзмененииКоличества(ИзмененнаяСтрока)
	// Рассчитывать сумму вызовом СуммаПоСтроке() и вызывать ПриИзмененииСуммы()  
	СуммаПоСтроке(ИзмененнаяСтрока); 
	ПриИзмененииСуммы(ИзмененнаяСтрока);
КонецПроцедуры

&НаКлиенте
Процедура ПриИзмененииЦены(ИзмененнаяСтрока)
	// Рассчитывать сумму вызовом СуммаПоСтроке() и вызывать ПриИзмененииСуммы() 
    СуммаПоСтроке(ИзмененнаяСтрока);
	ПриИзмененииСуммы(ИзмененнаяСтрока);
КонецПроцедуры  

&НаКлиенте
Процедура ПриИзмененииСкидки(ИзмененнаяСтрока)
	// Рассчитывать сумму вызовом СуммаПоСтроке() и вызывать ПриИзмененииСуммы()
	СуммаПоСтроке(ИзмененнаяСтрока);
	ПриИзмененииСуммы(ИзмененнаяСтрока);
КонецПроцедуры


&НаКлиенте
Процедура ПриИзмененииСуммы(ИзмененнаяСтрока)
	// Рассчитывать сумму НДС по сумме и ставке вызовом НДСКлиентСервер.СуммаНДСПоСтавке() 
	РассчитатьСуммаНДС (ИзмененнаяСтрока); 
	Если ИзмененнаяСтрока.Количество=0 или ИзмененнаяСтрока.Цена=0 Тогда
		Возврат;
	Иначе 
		ИзмененнаяСтрока.Скидка = 100 * (1 - ИзмененнаяСтрока.Сумма / ИзмененнаяСтрока.Количество / ИзмененнаяСтрока.Цена)   
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПриИзмененииСтавкиНДС(ИзмененнаяСтрока)
	// Рассчитывать сумму НДС по сумме и ставке вызовом НДСКлиентСервер.СуммаНДСПоСтавке() 
    РассчитатьСуммаНДС (ИзмененнаяСтрока);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыИУслугиКоличествоПриИзменении(Элемент)
	// Переопределить обработчики событий ПриИзменении полей ввода номенклатуры, 
	//количества, цены, скидки, суммы и ставки НДС, и вызывать из них процедуры 
	//ПриИзменении<...>, передавая в качестве параметра ТекущиеДанные таблицы.
    ТекДанные = Элементы.ТоварыИУслуги.ТекущиеДанные;
	  
	Если ТекДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ПриИзмененииКоличества(ТекДанные);
    
КонецПроцедуры

&НаКлиенте
Процедура ТоварыИУслугиЦенаПриИзменении(Элемент)
	// Переопределить обработчики событий ПриИзменении полей ввода номенклатуры, 
	//количества, цены, скидки, суммы и ставки НДС, и вызывать из них процедуры 
	//ПриИзменении<...>, передавая в качестве параметра ТекущиеДанные таблицы.
	
	ТекДанные = Элементы.ТоварыИУслуги.ТекущиеДанные;
	Если ТекДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	ПриИзмененииЦены(ТекДанные);  
	
КонецПроцедуры

&НаКлиенте
Процедура ТоварыИУслугиСуммаПриИзменении(Элемент)  
	/// Переопределить обработчики событий ПриИзменении полей ввода номенклатуры, 
	//количества, цены, скидки, суммы и ставки НДС, и вызывать из них процедуры 
	//ПриИзменении<...>, передавая в качестве параметра ТекущиеДанные таблицы.
	
	ТекДанные = Элементы.ТоварыИУслуги.ТекущиеДанные;
	Если ТекДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;    
	ПриИзмененииСуммы(ТекДанные);

КонецПроцедуры

&НаКлиенте
Процедура ТоварыИУслугиСтавкаНДСПриИзменении(Элемент)
	// Переопределить обработчики событий ПриИзменении полей ввода номенклатуры, 
	//количества, цены, скидки, суммы и ставки НДС, и вызывать из них процедуры 
	//ПриИзменении<...>, передавая в качестве параметра ТекущиеДанные таблицы.
	
	ТекДанные = Элементы.ТоварыИУслуги.ТекущиеДанные;
	Если ТекДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;    
	ПриИзмененииСтавкиНДС(ТекДанные);

КонецПроцедуры

&НаКлиенте
Процедура РассчитатьСуммаНДС (ИзмененнаяСтрока)
	//получим значения в колоках текущей строки - свойство табличной части ТекущиеДанные
	//Получим коллекцию. в которой есть все данные по строке
	Если ПустаяСтрока(ИзмененнаяСтрока.СтавкаНДС) Тогда
		Возврат;
	Иначе ИзмененнаяСтрока.СуммаНДС = НДСКлиентСервер.СуммаНДСПоСтавке(ИзмененнаяСтрока.Сумма, ИзмененнаяСтрока.СтавкаНДС);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ТоварыИУслугиНоменклатураПриИзменении(Элемент)
	// Переопределить обработчики событий ПриИзменении полей ввода номенклатуры, 
	//количества, цены, скидки, суммы и ставки НДС, и вызывать из них процедуры 
	//ПриИзменении<...>, передавая в качестве параметра ТекущиеДанные таблицы.
    ТекДанные = Элементы.ТоварыИУслуги.ТекущиеДанные;
	Если ТекДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;    
	ПриИзмененииНоменклатуры(ТекДанные);

КонецПроцедуры

&НаКлиенте
Процедура ТоварыИУслугиСкидкаПриИзменении(Элемент)
	// Переопределить обработчики событий ПриИзменении полей ввода номенклатуры, 
	//количества, цены, скидки, суммы и ставки НДС, и вызывать из них процедуры 
	//ПриИзменении<...>, передавая в качестве параметра ТекущиеДанные таблицы.  
	ТекДанные = Элементы.ТоварыИУслуги.ТекущиеДанные;
	Если ТекДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;    
	ПриИзмененииСкидки(ТекДанные);

КонецПроцедуры

&НаКлиенте
Процедура Подбор(Команда)
	// Добавить команду Подбор, разместив ее в командной панели таблицы цен. 
	//В обработчике команды открыть форму выбора справочника Номенклатура 
	//с параметром ЗакрыватьПриВыборе = Ложь, указав в качестве владельца таблицу ТоварыИУслуги. 
	//а в обработчике события ОбработкаВыбора вызывая процедуру ПриИзмененииНоменклатуры, 
	//чтобы обеспечить получение цен и скидок и автоматический пересчет сумм.

    ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ВыборГруппИЭлементов", ИспользованиеГруппИЭлементов.ГруппыИЭлементы);
	ПараметрыФормы.Вставить("ЗакрыватьПриВыборе", Ложь);
	ОткрытьФорму("Справочник.Номенклатура.ФормаВыбора", ПараметрыФормы, Элементы.ТоварыИУслуги);

КонецПроцедуры

&НаКлиенте
Процедура ТоварыИУслугиОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	//Переопределить событие ОбработкаВыбора таблицы товары и услуги. 
	//В обработчике отказаться от стандартной обработки и, 
	//если в таблице еще нет выбранного значения - добавить строку и 
	//вызвать процедуру ПриИзмененииНоменклатуры, передав добавленную строку.  
	СтандартнаяОбработка = Ложь;
	
	// Выполним поиск в таблице строки с этой номенклатурой;
	ОтборСтрок = Новый Структура ("Номенклатура", ВыбранноеЗначение);
	НайденныеСтрокиВСпискеВыбранных = Объект.ТоварыИУслуги.НайтиСтроки(ОтборСтрок);
	
	
	//Если строка не найдена - создадим новую строку, в колонку 
	//Номенклатура укажем выбранное значение, 	
	Если НайденныеСтрокиВСпискеВыбранных.Количество() = 0 Тогда
		
		НоваяСтрокаТаблицы = Объект.ТоварыИУслуги.Добавить();
		НоваяСтрокаТаблицы.Номенклатура = ВыбранноеЗначение;     
		ПриИзмененииНоменклатуры(НоваяСтрокаТаблицы);
		
	Иначе 
		Возврат;
	КонецЕсли;
	
КонецПроцедуры



```
+ ОМ НДСКлиенСервер (вызывается в процедуре РассчитатьСуммаНДС)
```bsl

Функция СуммаНДСПоСтавке(Сумма, СтавкаНДС)Экспорт

	//Создать функцию СуммаНДСПоСтавке(Сумма, СтавкаНДС), 
	//возвращающую сумму НДС, рассчитанную от суммы по ставке согласно требованиям. 
	//Чтобы обеспечить работоспособность на клиенте, 
	//для получения значений ставок НДС используйте функцию ПредопределенноеЗначение()	
	
	
	//НДС рассчитывается по ставкам, определяемым по значению перечисления 
	//СтавкиНДС (БезНДС - 0%, НДС10 - 10%, НДС20 - 20%). 
	//Сумма НДС определяется умножением суммы на ставку 
	//(т.е. НДС рассчитывается по схеме "в том числе", например, 
	//для ставки 20% и суммы 120 р сумма НДС будет равна 120 * 0.2 / (1 + 0.2) = 20.
	
	Если СтавкаНДС = ПредопределенноеЗначение("Перечисление.СтавкиНДС.БезНДС") Тогда
		Ставка = 0;
	ИначеЕсли СтавкаНДС = ПредопределенноеЗначение("Перечисление.СтавкиНДС.НДС10") Тогда
		Ставка = 0.1;
	ИначеЕсли СтавкаНДС = ПредопределенноеЗначение("Перечисление.СтавкиНДС.НДС20") Тогда
		Ставка = 0.2;     
	КонецЕсли;
	
	НДС = Сумма * Ставка / (1 + Ставка);
	
	Возврат НДС;
	
КонецФункции 
```

+ Модуль объекта документа с контролем остатков


  ```bsl
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


```

+ В результате получаем форму документа с реализацией автоматического заполненения цены и скидки, при изменении количества, цены и скидки пересчитывается сумма и сумма НДС, а при изменении суммы и ставки НДС - сумма НДС, при проведении происходит запись в регистры и контроль остатков

![image](https://github.com/user-attachments/assets/8c4acfcd-5532-4b98-8ebc-5767108ec897)

4. Реализлванные отчеты:

+ Взаиморасчеты с контрагентами
![image](https://github.com/user-attachments/assets/17934b58-3efb-40ac-85a0-b000ca9a4d61)

+ Движения товаров

![image](https://github.com/user-attachments/assets/a739a910-fce0-44c6-b273-15d2afb8f6c5)

+ Доходы и расходы

![image](https://github.com/user-attachments/assets/a4ecc6b0-6d34-4311-a96d-f57c44032c74)




   
