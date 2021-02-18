# Динамическая модель межотраслевого баланса

## Воспроизведение экспериментов:

### Собственное движение системы

example('USA', 2014, 'prev', 'rw')

example('USA', 2015, 'prev', 'none')

example('IND', 2014, 'prev', 'none')

example('IND', 2015, 'prev', 'none')

example('CHN', 2014, 'prev', 'none')

example('CHN', 2015, 'prev', 'none')

### Оптимальное управление

example('USA', 2014, 'prev', 'rw')

example('IND', 2014, 'prev', 'tp')
