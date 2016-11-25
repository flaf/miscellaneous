from django.http import HttpResponse


def index(request):
    # HttpResponse() permet de renvoyer une page Web (avec
    # son header etc.) avec un contenu.
    return HttpResponse("Hello, world. You're at the polls index.\n")

