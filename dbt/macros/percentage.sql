{% macro percentage(numerator, denominator) %}
    round(100.0 * {{ numerator }} / nullIf({{ denominator }}, 0), 2)
{% endmacro %}
