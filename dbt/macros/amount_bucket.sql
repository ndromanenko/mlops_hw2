{% macro amount_bucket(amount_column) %}
    multiIf(
        {{ amount_column }} < {{ var('small_amount_threshold') }}, 'small',
        {{ amount_column }} < {{ var('large_amount_threshold') }}, 'medium',
        {{ amount_column }} < {{ var('very_large_amount_threshold') }}, 'large',
        'very_large'
    )
{% endmacro %}
