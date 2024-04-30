from django.apps import AppConfig


class StocksConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'stocks'

    def ready(self):
        import stocks.templatetags.custom_filters     # Tady importujeme custom_filters, aby byl načten při spuštění Django
