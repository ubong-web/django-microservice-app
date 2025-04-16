from django.shortcuts import render

# Create your views here.
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .serializers import ProcessSerializer
from .tasks import process_data
from celery.result import AsyncResult

class ProcessView(APIView):
    def post(self, request):
        serializer = ProcessSerializer(data=request.data)
        if serializer.is_valid():
            task = process_data.delay(**serializer.validated_data)
            return Response({"task_id": task.id}, status=202)
        return Response(serializer.errors, status=400)

class StatusView(APIView):
    def get(self, request, task_id):
        result = AsyncResult(task_id)
        return Response({
            "task_id": task_id,
            "status": result.status,
            "result": result.result if result.successful() else None
        })
