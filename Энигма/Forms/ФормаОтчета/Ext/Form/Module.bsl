﻿
Процедура КоличествоСтрокПрочитать(Док=Неопределено)
	КоличествоСтрок	= 0;
	Если ЗначениеЗаполнено(Отчет.ФайлПаролей) Тогда
		Если Док = Неопределено Тогда
			Док = Новый ТекстовыйДокумент;
		КонецЕсли;
		Попытка
			Док.Прочитать(Отчет.ФайлПаролей);
			КоличествоСтрок	= Док.КоличествоСтрок();
		Исключение
			Сообщить("Файл не удалось открыть. " + Отчет.ФайлПаролей);
		КонецПопытки;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Функция БлетчлиПарк(Соединение, Знач Пароль, ОшибкиПоказывать=Ложь)
	Ответ	= Ложь;
	СтрПодключения = "Provider=" + ?(ПустаяСтрока(Отчет.Провайдер), "SQLOLEDB.1", Отчет.Провайдер) + ";server=" + Отчет.АдресСервера + ";uid=" + Отчет.Пользователь + ";pwd=" + Пароль;
	Если Соединение = Неопределено Тогда
	    Соединение = Новый COMОбъект("ADODB.Connection");
		Если Отчет.Таймаут > 0 Тогда
			Соединение.CommandTimeout = Отчет.Таймаут;
		КонецЕсли;
	КонецЕсли;
    Соединение.ConnectionString = СтрПодключения;
	Попытка
		Соединение.Open();
		Соединение.Close();
		Ответ	= Истина;
	Исключение
		//Соединение	= Неопределено;
		Если ОшибкиПоказывать Тогда
			Сообщить(ОписаниеОшибки());
		КонецЕсли;
	КонецПопытки;
	Возврат Ответ;
КонецФункции

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	КоличествоСтрокПрочитать();
	
	Элементы.Провайдер.СписокВыбора.Добавить("SQLOLEDB.1");
	Элементы.Провайдер.СписокВыбора.Добавить("PostgreSQL.1");
	Элементы.Провайдер.СписокВыбора.Добавить("IBMDADB2");
	Если ПустаяСтрока(Отчет.Провайдер) Тогда
		Отчет.Провайдер	= Элементы.Провайдер.СписокВыбора[0];
		
		Сообщить("Добро пожаловать!");
	КонецЕсли;
	
	Элементы.АдресСервера.СписокВыбора.Добавить("localhost");
	Если ПустаяСтрока(Отчет.АдресСервера) Тогда
		Отчет.АдресСервера	= Элементы.АдресСервера.СписокВыбора[0];
		Отчет.Таймаут		= 2;
	КонецЕсли;
	
	Элементы.Пользователь.СписокВыбора.Добавить("sa");
	Элементы.Пользователь.СписокВыбора.Добавить("USR1CV82");
	Если ПустаяСтрока(Отчет.Пользователь) Тогда
		Отчет.Пользователь	= Элементы.Пользователь.СписокВыбора[0];
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура НайтиПароль(Команда)
	Если ПустаяСтрока(Отчет.ФайлПаролей) Тогда
		Сообщить("Укажите файл паролей");
	Иначе
		Соединение	= Неопределено;
		ДокЭкспо = Новый ТекстовыйДокумент;
		КоличествоСтрокПрочитать(ДокЭкспо);
		
		Отчет.Пароль	= "";
		Начальная		= Макс(Отчет.НачатьСоСтроки, 1);
		НомерСтроки		= Начальная;
		Пока НомерСтроки <= КоличествоСтрок Цикл
			Старт		= ТекущаяУниверсальнаяДатаВМиллисекундах();
			ТекТекст = СокрЛП(ДокЭкспо.ПолучитьСтроку(НомерСтроки));
			Если НЕ ПустаяСтрока(ТекТекст) Тогда
				Если БлетчлиПарк(Соединение, ТекТекст) Тогда
					Отчет.Пароль	= ТекТекст;
					
					Сообщить("Имя пользователя " + Отчет.Пользователь + Символы.ПС + "Пароль " + Отчет.Пароль, СтатусСообщения.Важное);
					Прервать;
					
				ИначеЕсли Цел(НомерСтроки / 100) * 100 = НомерСтроки И НомерСтроки > Отчет.НачатьСоСтроки Тогда
					Если Цел(НомерСтроки / 1000) * 1000 = НомерСтроки Тогда
						ОчиститьСообщения();
					КонецЕсли;
					
					Отчет.НачатьСоСтроки	= НомерСтроки;
					Сообщить("Строка " + Строка(НомерСтроки) + ". Скорость " + Строка(Окр((НомерСтроки - Начальная) / (ТекущаяУниверсальнаяДатаВМиллисекундах() - Старт), 1)), СтатусСообщения.Информация);
				КонецЕсли;
			КонецЕсли;
			ОбработкаПрерыванияПользователя();
			
			НомерСтроки = НомерСтроки + 1;
		КонецЦикла;
		Если ПустаяСтрока(Отчет.Пароль) Тогда
			Сообщить("Найти не удалось", СтатусСообщения.Внимание);
		КонецЕсли;
		Отчет.НачатьСоСтроки	= Макс(НомерСтроки - 1, 0);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ТестПодключения(Команда)
	Соединение = Неопределено;
	Если БлетчлиПарк(Соединение, Отчет.Пароль, Истина) Тогда
		Сообщить("Ok");
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ФайлПаролейНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	
	ДиалогВыбораФайла = ДиалогВыбораФайлаИмпортаСоздать();
	Если ДиалогВыбораФайла = Неопределено Тогда
		
	ИначеЕсли ДиалогВыбораФайла.Выбрать() Тогда
		Отчет.ФайлПаролей	= ДиалогВыбораФайла.ПолноеИмяФайла;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Функция ДиалогВыбораФайлаИмпортаСоздать(МножественныйВыбор=Ложь) Экспорт
	#Если ВебКлиент Тогда
		Если НЕ ПодключитьРасширениеРаботыСФайлами() Тогда
			УстановитьРасширениеРаботыСФайлами();
			Если НЕ ПодключитьРасширениеРаботыСФайлами() Тогда
				Сообщить("В Веб-клиенте без установленного расширения работы с файлами выбор файлов не поддерживается");
				Возврат Неопределено;
			КонецЕсли;
		КонецЕсли;
	#КонецЕсли
	ДиалогВыбораФайла =	Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДиалогВыбораФайла.Фильтр						= "Файл паролей (*.dic)|*.dic|Текстовый файл (*.txt)|*.txt";
	ДиалогВыбораФайла.Заголовок						= "Выберите файл";
	ДиалогВыбораФайла.МножественныйВыбор			= Ложь;
	ДиалогВыбораФайла.ПредварительныйПросмотр		= Ложь;
	ДиалогВыбораФайла.ПроверятьСуществованиеФайла	= Истина;
	Возврат ДиалогВыбораФайла;
КонецФункции

&НаКлиенте
Процедура ТаймаутРегулирование(Элемент, Направление, СтандартнаяОбработка)
	Если Отчет.Таймаут > 99 И Направление > 0 Или Отчет.Таймаут > 199 И Направление < 0 Тогда
		СтандартнаяОбработка	= Ложь;
		
		Отчет.Таймаут = Отчет.Таймаут + 100 * Направление;
		
	ИначеЕсли Отчет.Таймаут > 9 И Направление > 0 Или Отчет.Таймаут > 19 И Направление < 0 Тогда
		СтандартнаяОбработка	= Ложь;
		
		Отчет.Таймаут = Отчет.Таймаут + 10 * Направление;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ФайлПаролейПриИзменении(Элемент)
	КоличествоСтрокПрочитать();
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, СтандартнаяОбработка)
	Если ПустаяСтрока(Отчет.Провайдер) Тогда
		Отчет.Провайдер	= Элементы.Провайдер.СписокВыбора[0];
	КонецЕсли;
КонецПроцедуры
