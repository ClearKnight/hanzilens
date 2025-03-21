import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzilens/app/routes.dart';
import 'package:hanzilens/app/theme.dart';
import 'package:hanzilens/core/di/injection.dart';
import 'package:hanzilens/presentation/blocs/camera/camera_bloc.dart';
import 'package:hanzilens/presentation/blocs/recognition/recognition_bloc.dart';

class HanziLensApp extends StatelessWidget {
  const HanziLensApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // 相机BLoC
        BlocProvider<CameraBloc>(
          create: (_) => getIt<CameraBloc>()..add(const InitializeCamera()),
        ),
        // 识别BLoC
        BlocProvider<RecognitionBloc>(
          create: (_) => getIt<RecognitionBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'HanziLens',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        navigatorKey: AppRouter.navigatorKey,
        onGenerateRoute: AppRoutes.generateRoute,
        initialRoute: AppRoutes.home,
      ),
    );
  }
}
