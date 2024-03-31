
Процедура МассовоеСозданиеАктов(Параметры, АдресРезультата) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ДоговорыКонтрагентов.Ссылка КАК Договор,
	|	ДоговорыКонтрагентов.Владелец КАК Контрагент,
	|	NULL КАК Регистратор,
	|	ДоговорыКонтрагентов.Организация
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	|ГДЕ
	|	ДоговорыКонтрагентов.ВидДоговора = &ВидДоговора
	|СГРУППИРОВАТЬ ПО
	|	ДоговорыКонтрагентов.Ссылка,
	|	ДоговорыКонтрагентов.Владелец,
	|	ДоговорыКонтрагентов.Организация
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ВКМ_ВыполненныеКлиентуРаботы.ВКМ_Договор,
	|	ВКМ_ВыполненныеКлиентуРаботы.ВКМ_Клиент,
	|	ВКМ_ВыполненныеКлиентуРаботы.Регистратор,
	|	NULL
	|ИЗ
	|	РегистрНакопления.ВКМ_ВыполненныеКлиентуРаботы КАК ВКМ_ВыполненныеКлиентуРаботы
	|ГДЕ
	|	ВКМ_ВыполненныеКлиентуРаботы.ВидДвижения = &ВидДвижения
	|	И ВКМ_ВыполненныеКлиентуРаботы.Период МЕЖДУ &ПериодНачало И &ПериодОкончание
	|СГРУППИРОВАТЬ ПО
	|	ВКМ_ВыполненныеКлиентуРаботы.ВКМ_Договор,
	|	ВКМ_ВыполненныеКлиентуРаботы.ВКМ_Клиент,
	|	ВКМ_ВыполненныеКлиентуРаботы.Регистратор";
	
	Запрос.УстановитьПараметр("ПериодНачало", Параметры.НачалоПериода);
	Запрос.УстановитьПараметр("ПериодОкончание", Параметры.КонецПериода);
	Запрос.УстановитьПараметр("ВидДвижения", ВидДвиженияНакопления.Приход);
	Запрос.УстановитьПараметр("ВидДоговора", Перечисления.ВидыДоговоровКонтрагентов.ВКМ_АбонентскоеОбслуживание);
	
	МассивВозврат = Новый Массив;
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		Если НЕ ЗначениеЗаполнено(Выборка.Регистратор) Тогда
			
			СтруктураМассива = Новый Структура;
			НовыйДокумент = Документы.РеализацияТоваровУслуг.СоздатьДокумент();
			НовыйДокумент.Заполнить(Выборка);
			НовыйДокумент.ВыполнитьАвтозаполнение(Параметры.НачалоПериода, Параметры.КонецПериода, Выборка.Организация, Выборка.Договор);
				
				Если НовыйДокумент.ПроверитьЗаполнение() Тогда
    				НовыйДокумент.Записать();
    				СтруктураМассива.Вставить("ВКМ_Договор", Выборка.Договор);
    				СтруктураМассива.Вставить("ВКМ_Реализация", НовыйДокумент);
    				СтруктураМассива.Вставить("Организация", Выборка.Организация);
    				МассивВозврат.Добавить(СтруктураМассива);
				КонецЕсли;
				
		Иначе
			Продолжить;
		КонецЕсли;
		
	КонецЦикла;
	
	ПоместитьВоВременноеХранилище(МассивВозврат, АдресРезультата);

КонецПроцедуры
