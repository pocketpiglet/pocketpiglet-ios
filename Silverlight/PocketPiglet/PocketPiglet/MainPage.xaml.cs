using System;
using System.Collections.Generic;
using System.IO;
using System.IO.IsolatedStorage;
using System.Linq;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Windows.Threading;
using Microsoft.Devices.Sensors;
using Microsoft.Phone.Controls;
using Microsoft.Phone.Tasks;

namespace PocketPiglet
{
    public partial class MainPage : PhoneApplicationPage
    {
        private DispatcherTimer timerAnimationPigletStart;
        private DispatcherTimer timerAnimationPigletStop;
        private DispatcherTimer timerAnimationPigletDefault;
        private DispatcherTimer timerAnimationPigletInSorrow;
        private Random rnd;
        private int countDefaultAnimation;
        private int deltaTimeDefaultAnimation = 250;
        private int deltaTimeGameAnimation = 100;
        private const int MODE_ANIMATION_DEFAULT = 1,
                          MODE_ANIMATION_GAME = 2;

        private int typeAnimation;
        private string animationPigletPlay;
        private SensorReadingEventArgs<AccelerometerReading> _lastReading;
        private Point pointMovePiglet;
        private bool isPlayVideoLaughs;
        private bool isPigletInSorrow;
        private string lastGamePiglet;
        private MarketplaceDetailTask marketplaceDetailTask;

        private bool feedGameState = true;
        private bool washGameState = true;
        private bool puzzleGameState = true;

        private readonly Accelerometer _sensor = new Accelerometer();

        public MainPage()
        {
            InitializeComponent();
            this.isPlayVideoLaughs = false;
            this.isPigletInSorrow = false;
            _sensor.CurrentValueChanged += new EventHandler<SensorReadingEventArgs<AccelerometerReading>>(sensor_CurrentValueChanged);
            _sensor.Start();
            this.countDefaultAnimation = 0;
            this.timerAnimationPigletStart = new System.Windows.Threading.DispatcherTimer();
            this.timerAnimationPigletStart.Tick += new EventHandler(timerAnimationPigletStart_Tick);
            this.timerAnimationPigletStart.Interval = new TimeSpan(0, 0, 0, 0, 300);

            this.timerAnimationPigletStop = new System.Windows.Threading.DispatcherTimer();
            this.timerAnimationPigletStop.Tick += new EventHandler(timerAnimationPigletStop_Tick);

            this.timerAnimationPigletInSorrow = new System.Windows.Threading.DispatcherTimer();
            this.timerAnimationPigletInSorrow.Tick += new EventHandler(timerAnimationPigletInSorrow_Tick);
            this.timerAnimationPigletInSorrow.Interval = new TimeSpan(0, 0, 0, 60, 0);
            this.timerAnimationPigletInSorrow.Start();

            this.rnd = new Random();
            int timeRandomDefaultAnimation = this.rnd.Next(1, 3);
            this.timerAnimationPigletDefault = new System.Windows.Threading.DispatcherTimer();
            this.timerAnimationPigletDefault.Tick += new EventHandler(timerRandomDefaultAnimation_Tick);
            this.timerAnimationPigletDefault.Interval = new TimeSpan(0, 0, 0, timeRandomDefaultAnimation, 0);
            this.timerAnimationPigletDefault.Start();

            this.marketplaceDetailTask                   = new MarketplaceDetailTask();
#if DEBUG_TRIAL
            this.marketplaceDetailTask.ContentType       = MarketplaceContentType.Applications;
            this.marketplaceDetailTask.ContentIdentifier = "a5cf363a-044a-46f0-a414-9235cc31f997";
#endif
        }

        private void sensor_CurrentValueChanged(object sender, SensorReadingEventArgs<AccelerometerReading> e)
        {
            Deployment.Current.Dispatcher.BeginInvoke(delegate()
            {
                double threshold = 1.0;
                if (_lastReading != null)
                {
                    double deltaX = Math.Abs((_lastReading.SensorReading.Acceleration.X - e.SensorReading.Acceleration.X));
                    double deltaY = Math.Abs((_lastReading.SensorReading.Acceleration.Y - e.SensorReading.Acceleration.Y));
                    double deltaZ = Math.Abs((_lastReading.SensorReading.Acceleration.Z - e.SensorReading.Acceleration.Z));
                    if ((deltaX > threshold && deltaY > threshold) || (deltaX > threshold && deltaZ > threshold) || (deltaY > threshold && deltaZ > threshold))
                    {
                        _lastReading = null;
                        _sensor.Stop();
                        this.ImagePigletCake_PlayVideoFalls();
                        return;
                    }
                }
                _lastReading = e;
            });
        }

        private void timerRandomDefaultAnimation_Tick(object sender, EventArgs e)
        {
            this.timerAnimationPigletDefault.Stop();
            if (this.MediaPigletVideo.CurrentState == MediaElementState.Playing)
            {
                int timeRandomDefaultAnimation = this.rnd.Next(1, 3);
                this.timerAnimationPigletDefault.Interval = new TimeSpan(0, 0, 0, timeRandomDefaultAnimation, 0);
                this.timerAnimationPigletDefault.Start();
            }
            else
            {
                if (this.countDefaultAnimation >= 2)
                {
                    this.countDefaultAnimation = 0;
                    this.typeAnimation = MODE_ANIMATION_DEFAULT;
                    if (this.isPigletInSorrow)
                    {
                        this.MediaPigletVideo.Source = new Uri("/Video/piglet_in_sorrow.mp4", UriKind.Relative);
                    }
                    else
                    {
                        this.MediaPigletVideo.Source = new Uri("/Video/piglet_look_around.mp4", UriKind.Relative);
                    }
                    this.MediaPigletVideo.Play();
                }
                else
                {
                    this.typeAnimation = MODE_ANIMATION_DEFAULT;
                    this.MediaPigletVideo.Source = new Uri("/Video/piglet_eyes_blink.mp4", UriKind.Relative);
                    this.MediaPigletVideo.Play();
                    this.countDefaultAnimation++;
                }
            }
        }

        private void timerAnimationPigletStart_Tick(object sender, EventArgs e)
        {
            if (this.typeAnimation == MODE_ANIMATION_GAME) this._sensor.Stop();
            this.ImagePigletIdle.Visibility = Visibility.Collapsed;
            this.timerAnimationPigletStart.Stop();
        }

        private void timerAnimationPigletStop_Tick(object sender, EventArgs e)
        {
            this.ImagePigletIdle.Visibility = Visibility.Visible;
            this.MediaPigletVideo.Stop();
            this.timerAnimationPigletStop.Stop();

            int timeRandomDefaultAnimation = this.rnd.Next(1, 3);
            this.timerAnimationPigletDefault.Interval = new TimeSpan(0, 0, 0, timeRandomDefaultAnimation, 0);
            this.timerAnimationPigletDefault.Start();
            this._sensor.Start();

        }

        private void PigletCandy_MouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            this.ImagePigletIdle.Visibility = Visibility.Visible;
            this.MediaPigletVideo.Stop();
            this.typeAnimation = MODE_ANIMATION_GAME;
            this.MediaPigletVideo.Source = new Uri("/Video/piglet_eats_candy.mp4", UriKind.Relative);
            this.MediaPigletVideo.Play();

        }

        private void ImagePigletCake_MouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            this.ImagePigletIdle.Visibility = Visibility.Visible;
            this.MediaPigletVideo.Stop();
            this.typeAnimation = MODE_ANIMATION_GAME;
            this.MediaPigletVideo.Source = new Uri("/Video/piglet_eats_cake.mp4", UriKind.Relative);
            this.MediaPigletVideo.Play();
        }

        private void ImagePigletCake_PlayVideoFalls()
        {
            this.ImagePigletIdle.Visibility = Visibility.Visible;
            this.MediaPigletVideo.Stop();
            this.typeAnimation = MODE_ANIMATION_GAME;
            this.MediaPigletVideo.Source = new Uri("/Video/piglet_falls.mp4", UriKind.Relative);
            this.MediaPigletVideo.Play();
        }

        private void ImagePigletCake_PlayVideoLaughs()
        {
            this.ImagePigletIdle.Visibility = Visibility.Visible;
            this.MediaPigletVideo.Stop();
            this.typeAnimation = MODE_ANIMATION_GAME;
            this.MediaPigletVideo.Source = new Uri("/Video/piglet_laughs.mp4", UriKind.Relative);
            this.MediaPigletVideo.Play();
        }

        private void ImagePigletCake_PlayVideoInSorrow()
        {
            this.ImagePigletIdle.Visibility = Visibility.Visible;
            this.MediaPigletVideo.Stop();
            this.typeAnimation = MODE_ANIMATION_GAME;
            this.MediaPigletVideo.Source = new Uri("/Video/piglet_in_sorrow.mp4", UriKind.Relative);
            this.MediaPigletVideo.Play();
        }

        private void MediaPigletVideo_CurrentStateChanged(object sender, RoutedEventArgs e)
        {
            if (this.MediaPigletVideo.CurrentState == MediaElementState.Playing)
            {
                this.timerAnimationPigletStart.Start();
                Duration durationAnimation = this.MediaPigletVideo.NaturalDuration;
                TimeSpan timeSpan = durationAnimation.TimeSpan;
                int delta = 300;
                if (this.typeAnimation == MODE_ANIMATION_DEFAULT)
                {
                    delta = this.deltaTimeDefaultAnimation;
                }
                if (this.typeAnimation == MODE_ANIMATION_GAME)
                {
                    delta = this.deltaTimeGameAnimation;
                }
                timeSpan = timeSpan.Subtract(new TimeSpan(0, 0, 0, 0, delta));
                this.timerAnimationPigletStop.Interval = timeSpan;
                this.timerAnimationPigletStop.Start();
            }
        }

        private void ImagePigletFeed_MouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            NavigationService.Navigate(new Uri("/FeedSelectionComplexityPage.xaml", UriKind.Relative));
        }

        private void ImagePigletWash_MouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            if ((Application.Current as App).TrialMode)
            {
                MessageBoxResult result = MessageBox.Show(AppResources.MessageBoxMessageTrialVersionQuestion, AppResources.MessageBoxHeaderInfo, MessageBoxButton.OKCancel);

                if (result == MessageBoxResult.OK)
                {
                    try
                    {
                        this.marketplaceDetailTask.Show();
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show(AppResources.MessageBoxMessageMarketplaceOpenError + " " + ex.Message.ToString(), AppResources.MessageBoxHeaderError, MessageBoxButton.OK);
                    }
                }
            }
            else
            {
                NavigationService.Navigate(new Uri("/WashPage.xaml", UriKind.Relative));
            }
        }

        private void ImagePigletPuzzle_MouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            if ((Application.Current as App).TrialMode)
            {
                MessageBoxResult result = MessageBox.Show(AppResources.MessageBoxMessageTrialVersionQuestion, AppResources.MessageBoxHeaderInfo, MessageBoxButton.OKCancel);

                if (result == MessageBoxResult.OK)
                {
                    try
                    {
                        this.marketplaceDetailTask.Show();
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show(AppResources.MessageBoxMessageMarketplaceOpenError + " " + ex.Message.ToString(), AppResources.MessageBoxHeaderError, MessageBoxButton.OK);
                    }
                }
            }
            else
            {
                NavigationService.Navigate(new Uri("/PuzzlePage.xaml", UriKind.Relative));
            }
        }

        protected override void OnNavigatedTo(NavigationEventArgs e)
        {

            base.OnNavigatedTo(e);
            IsolatedStorageSettings.ApplicationSettings.TryGetValue<string>("AnimationPigletPlay", out this.animationPigletPlay);
            if (this.animationPigletPlay != null && this.animationPigletPlay != "")
            {
                this.timerAnimationPigletDefault.Stop();
                if ("WashPigletAnimation" == this.animationPigletPlay)
                {
                    this.MediaPigletVideo.Source = new Uri("/Video/piglet_wash_game_finished.mp4", UriKind.Relative);
                }
                if ("FeedPigletAnimation" == this.animationPigletPlay)
                {
                    this.MediaPigletVideo.Source = new Uri("/Video/piglet_feed_game_finished.mp4", UriKind.Relative);
                }
                this.ImagePigletIdle.Visibility = Visibility.Visible;
                this.MediaPigletVideo.Stop();
                this.typeAnimation = MODE_ANIMATION_GAME;
                this.MediaPigletVideo.Play();
            }
            else {
                this.timerAnimationPigletDefault.Start();
            }
            IsolatedStorageSettings.ApplicationSettings["AnimationPigletPlay"] = "";
            IsolatedStorageSettings.ApplicationSettings.Save();
            IsolatedStorageSettings.ApplicationSettings.TryGetValue<bool>("FeedGameState", out this.feedGameState);
            IsolatedStorageSettings.ApplicationSettings.TryGetValue<bool>("WashGameState", out this.washGameState);
            IsolatedStorageSettings.ApplicationSettings.TryGetValue<bool>("PuzzleGameState", out this.puzzleGameState);

            if (!this.feedGameState || !this.washGameState || !this.puzzleGameState)
            {
                this.isPigletInSorrow = true;
            }
            else
            {
                this.isPigletInSorrow = false;
            }
            if (!this.feedGameState)
            {
                this.ImagePigletFeed.Source = new BitmapImage(new Uri("/Images/game_piglet_feed_highlighted.png", UriKind.Relative));
            }
            else
            {
                this.ImagePigletFeed.Source = new BitmapImage(new Uri("/Images/game_piglet_feed.png", UriKind.Relative));
            }
            if (!this.washGameState)
            {
                this.ImagePigletWash.Source = new BitmapImage(new Uri("/Images/game_piglet_wash_highlighted.png", UriKind.Relative));
            }
            else
            {
                this.ImagePigletWash.Source = new BitmapImage(new Uri("/Images/game_piglet_wash.png", UriKind.Relative));
            }
            if (!this.puzzleGameState)
            {
                this.ImagePigletPuzzle.Source = new BitmapImage(new Uri("/Images/game_piglet_puzzle_highlighted.png", UriKind.Relative));
            }
            else
            {
                this.ImagePigletPuzzle.Source = new BitmapImage(new Uri("/Images/game_piglet_puzzle.png", UriKind.Relative));
            }
            this.timerAnimationPigletInSorrow.Start();
        }

        private void timerAnimationPigletInSorrow_Tick(object sender, EventArgs e)
        {
            IsolatedStorageSettings.ApplicationSettings.TryGetValue<bool>("FeedGameState", out this.feedGameState);
            IsolatedStorageSettings.ApplicationSettings.TryGetValue<bool>("WashGameState", out this.washGameState);
            IsolatedStorageSettings.ApplicationSettings.TryGetValue<bool>("PuzzleGameState", out this.puzzleGameState);
            IsolatedStorageSettings.ApplicationSettings.TryGetValue<string>("LastGamePiglet", out this.lastGamePiglet);
            List<string> listGame = new List<string>();
            if (this.feedGameState && this.lastGamePiglet != "feed") listGame.Add("feed");
            if (this.washGameState && this.lastGamePiglet != "wash") listGame.Add("wash");
            if (this.puzzleGameState && this.lastGamePiglet != "puzzle") listGame.Add("puzzle");
            if (this.feedGameState && this.washGameState && this.puzzleGameState && listGame.Count != 0)
            {
                this.isPigletInSorrow = true;
                string typeGame = listGame[this.rnd.Next(0, listGame.Count)];
                if (typeGame == "feed")
                {
                    IsolatedStorageSettings.ApplicationSettings["FeedGameState"] = false;
                    this.ImagePigletFeed.Source = new BitmapImage(new Uri("/Images/game_piglet_feed_highlighted.png", UriKind.Relative));
                }
                if (typeGame == "wash")
                {
                    IsolatedStorageSettings.ApplicationSettings["WashGameState"] = false;
                    this.ImagePigletWash.Source = new BitmapImage(new Uri("/Images/game_piglet_wash_highlighted.png", UriKind.Relative));
                }
                if (typeGame == "puzzle")
                {
                    IsolatedStorageSettings.ApplicationSettings["PuzzleGameState"] = false;
                    this.ImagePigletPuzzle.Source = new BitmapImage(new Uri("/Images/game_piglet_puzzle_highlighted.png", UriKind.Relative));
                }
            }
            IsolatedStorageSettings.ApplicationSettings["LastGamePiglet"] = "";
            IsolatedStorageSettings.ApplicationSettings.Save();
        }

        protected override void OnNavigatingFrom(NavigatingCancelEventArgs e)
        {
            this.timerAnimationPigletInSorrow.Stop();
            this.timerAnimationPigletDefault.Stop();
            this.ImagePigletIdle.Visibility = Visibility.Visible;
            this.MediaPigletVideo.Stop();
        }

        private void LayoutRoot_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            this.pointMovePiglet = e.GetPosition(this);
        }

        private void LayoutRoot_MouseMove(object sender, MouseEventArgs e)
        {
            if (!this.isPlayVideoLaughs)
            {
                if (this.MediaPigletVideo.CurrentState != MediaElementState.Playing || (this.MediaPigletVideo.CurrentState == MediaElementState.Playing && this.typeAnimation == MODE_ANIMATION_DEFAULT))
                {
                    e.GetPosition(this);
                    double deltaX = Math.Abs(e.GetPosition(this).X - this.pointMovePiglet.X);
                    double deltaY = Math.Abs(e.GetPosition(this).Y - this.pointMovePiglet.Y);
                    if (deltaX > 30 || deltaY > 50)
                    {
                        if (this.isPigletInSorrow)
                        {
                            this.ImagePigletCake_PlayVideoInSorrow();
                        }
                        else
                        {
                            this.ImagePigletCake_PlayVideoLaughs();
                        }
                        this.isPlayVideoLaughs = true;
                    }
                }
            }
        }

        private void LayoutRoot_MouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            this.isPlayVideoLaughs = false; ;
        }

        private void ImageHelp_MouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            NavigationService.Navigate(new Uri("/HelpPage.xaml", UriKind.Relative));
        }
    }
}