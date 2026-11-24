# NovaFab Components | Análisis de operaciones industriales

¿Las máquinas que requieren mantenimiento correctivo con más frecuencia también pierden más tiempo durante la producción? Analizo 9.000 lotes, 36 máquinas y 516 intervenciones de mantenimiento de una fábrica ficticia durante 2025. El estudio forma parte de la prueba de Python del itinerario de Data Analytics de IT Academy, Barcelona Activa.

**Autor:** Derian Palma Quirós · Ingeniero en Mecatrónica

[Ver el análisis con sus cinco gráficos](NovaFab_2025.ipynb)

## Resultados

| Pregunta | Resultado |
| --- | --- |
| ¿Qué línea supera más su ritmo objetivo? | La línea B alcanza un índice de 114 durante el tiempo activo. Un valor de 100 representa el ritmo previsto para los productos fabricados. |
| ¿Dónde pesan más las paradas? | B pierde el 8,81 % de sus horas de lote. En toda la planta, 210 lotes concentran el 31,7 % del tiempo de paro. |
| ¿Coinciden correctivos y paradas? | Las 18 máquinas con más correctivos por 1.000 horas de lote pierden 7,24 horas por cada 100 horas de lote. Las otras 18 pierden 5,29. |
| ¿Cómo cambia la calidad con la complejidad? | Entre las unidades inspeccionadas, las defectuosas pasan del 0,89 % en productos de complejidad baja al 2,71 % en los de complejidad alta. |
| ¿Cuánto influye la mezcla de productos al comparar turnos? | La brecha noche–mañana baja de 0,49 a 0,22 puntos porcentuales al ponderar ambos turnos con la misma distribución de complejidad. |

Investigaría primero las averías recurrentes de B. Los registros permiten señalar esa línea como prioridad, aunque vincular cada parada con una avería concreta exige recoger su causa y orden de trabajo. En calidad, propongo probar una verificación de la primera pieza en productos de complejidad alta y medir su efecto sobre las unidades inspeccionadas.

## Reproducir el análisis

1. Descarga el repositorio y abre una terminal en la carpeta que contiene el cuaderno y los cinco CSV.
2. Instala las dependencias y abre el cuaderno.

```bash
python -m pip install -r requirements.txt
python -m jupyter lab NovaFab_2025.ipynb
```

3. Ejecuta las celdas en orden. En Google Colab también puedes abrir el cuaderno y subir los cinco CSV al directorio de trabajo de la sesión.

## Datos del caso

Los cinco CSV contienen datos sintéticos del ejercicio NovaFab Components. Cada lote de producción tiene un control de calidad y está asociado con una máquina y un producto. Cada intervención de mantenimiento se registra por máquina. El diccionario explica las unidades y las convenciones de muestreo.

[Diccionario de datos](data_dictionary.txt) · [Modelo relacional](relational_model.webp)
