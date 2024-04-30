# custom_filters.py

from django import template

register = template.Library()

@register.filter
def is_number(value):
    try:
        float(value)
        return True
    except ValueError:
        return False
