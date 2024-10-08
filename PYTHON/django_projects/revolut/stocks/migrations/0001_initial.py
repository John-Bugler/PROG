# Generated by Django 4.2.7 on 2023-11-30 17:24

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='StockData',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('ticker', models.CharField(max_length=10)),
                ('trades', models.IntegerField()),
                ('quantity', models.DecimalField(decimal_places=2, max_digits=10)),
                ('avg_price', models.DecimalField(decimal_places=2, max_digits=10)),
                ('wavg_price', models.DecimalField(decimal_places=2, max_digits=10)),
                ('actual_price', models.DecimalField(decimal_places=2, max_digits=10)),
                ('actual_price_date', models.DateTimeField()),
                ('act_prices_count', models.IntegerField()),
                ('profit', models.DecimalField(decimal_places=1, max_digits=10)),
            ],
            options={
                'ordering': ['ticker', '-actual_price_date'],
            },
        ),
    ]
