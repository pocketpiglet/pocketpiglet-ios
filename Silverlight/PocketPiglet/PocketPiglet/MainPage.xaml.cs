using System;
using System.Collections.Generic;
using System.IO;
using System.IO.IsolatedStorage;
using System.Linq;
using System.Net;
using System.Threading;
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
using Microsoft.Xna.Framework.Audio;

namespace PocketPiglet
{
    public partial class MainPage : PhoneApplicationPage
    {
        private DispatcherTimer timerAnimationPigletStart;
        private DispatcherTimer timerAnimationPigletStop;
        private DispatcherTimer timerAnimationPigletDefault;
        private DispatcherTimer timerAnimationPigletInSorrow;
        private DispatcherTimer timerTrialTalk;
        private Random rnd;
        private int countDefaultAnimation;
        private int deltaTimeDefaultAnimation = 350;
        private int deltaTimeGameAnimation = 100;
        private const int MODE_ANIMATION_DEFAULT = 1,
                          MODE_ANIMATION_GAME    = 2;

        private int typeAnimation;
        private string animationPigletPlay;
        private SensorReadingEventArgs<AccelerometerReading> _lastReading;
        private Point pointMovePiglet;
        private bool isPlayVideoLaughs;
        private bool isPigletInSorrow;
        private bool isPigletTalk;
        private bool isPigletTalkAvailable;
        private string lastGamePiglet;
        private MarketplaceDetailTask marketplaceDetailTask;

        private bool startAnimationsOnLayoutUpdate = false;
        private bool pageNavigationComplete = false;
        private bool feedGameState = true;
        private bool washGameState = true;
        private bool puzzleGameState = true;
        private bool isPigletTalkDisabledByTrial = false;

        private const int STATE_LISTENING = 1,
                          STATE_RECORDING = 2,
                          STATE_PLAYING   = 3;
        private const int MAX_SAMPLE_RATE = 48000;
        private const int MAX_STREAM_DURATION = 60;
        private const int MAX_TRIAL_TALK_DURATION = 60;
        private const double VAD_THRESHOLD = 0.1F;

        private int vadState;
        private byte[] buffer;
        private MemoryStream stream;
        private DispatcherTimer timerPigletTalk;
        private DispatcherTimer timerPigletListening;
        private Microphone microphone;
        private int durationTalkPiglet;

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

            this.rnd = new Random();
            int timeRandomDefaultAnimation = this.rnd.Next(1, 3);

            this.timerAnimationPigletDefault = new System.Windows.Threading.DispatcherTimer();
            this.timerAnimationPigletDefault.Tick += new EventHandler(timerRandomDefaultAnimation_Tick);
            this.timerAnimationPigletDefault.Interval = new TimeSpan(0, 0, 0, timeRandomDefaultAnimation, 0);

            this.timerPigletListening = new System.Windows.Threading.DispatcherTimer();
            this.timerPigletListening.Tick += new EventHandler(timerPigletListening_Tick);

            this.vadState = STATE_LISTENING;
            this.stream = new MemoryStream();

            this.timerPigletTalk = new DispatcherTimer();
            this.timerPigletTalk.Tick += new EventHandler(timerPigletTalk_Tick);

            this.microphone = Microphone.Default;
            this.microphone.BufferDuration = TimeSpan.FromMilliseconds(500);
            this.microphone.BufferReady += new EventHandler<EventArgs>(microphone_BufferReady);
            this.microphone.Start();

            this.buffer = new byte[microphone.GetSampleSizeInBytes(microphone.BufferDuration)];

            this.timerTrialTalk = new System.Windows.Threading.DispatcherTimer();
            this.timerTrialTalk.Tick +=new EventHandler(timerTrialTalk_Tick);
            this.timerTrialTalk.Interval = TimeSpan.FromSeconds(MAX_TRIAL_TALK_DURATION);
            this.timerTrialTalk.Start();

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
                        this.PlayVideoFalls();
                        return;
                    }
                }
                _lastReading = e;
            });
        }

        private void microphone_BufferReady(object sender, EventArgs e)
        {
            this.microphone.GetData(buffer);

            if (this.isPigletTalkAvailable)
            {
                if (this.vadState == STATE_LISTENING || this.vadState == STATE_RECORDING)
                {
                    bool voice_found = false;

                    for (int i = 0; i < this.buffer.Length; i = i + 2)
                    {
                        double normalized = Math.Abs(BitConverter.ToInt16(this.buffer, i) / 32768.0F);

                        if (normalized > VAD_THRESHOLD)
                        {
                            voice_found = true;
                            break;
                        }
                    }

                    if (voice_found && !this.isPigletTalkDisabledByTrial && this.stream.Length < microphone.GetSampleSizeInBytes(TimeSpan.FromSeconds(MAX_STREAM_DURATION)))
                    {
                        this.vadState = STATE_RECORDING;

                        setPigletListen();

                        this.stream.Write(buffer, 0, buffer.Length);
                    }
                    else if (this.stream.Length > 0)
                    {
                        this.vadState = STATE_PLAYING;

                        playAudio();

                        this.stream.SetLength(0);
                    }
                }
            }
        }

        private void setPigletListen()
        {
            this.isPigletTalk = true;
            this.ImagePigletTalk.Source = new BitmapImage(new Uri("/Images/fonem/listen.png", UriKind.Relative));
            this.ImagePigletTalk.Visibility = Visibility.Visible;
            this.ImagePigletIdle.Visibility = Visibility.Collapsed;
            this.MediaPigletVideo.Stop();
            this.timerAnimationPigletStart.Stop();
            this.timerAnimationPigletStop.Stop();
            this.timerAnimationPigletDefault.Stop();
        }

        private void playAudio()
        {
            byte[] original_sound = this.stream.ToArray();
            byte[] accelerated_sound = new byte[original_sound.Length / 2];

            for (int i = 0; i < original_sound.Length; i = i + 4)
            {
                int first_lvl = BitConverter.ToInt16(original_sound, i);
                int second_lvl = BitConverter.ToInt16(original_sound, i);

                byte[] average = BitConverter.GetBytes((short)((first_lvl + second_lvl) / 2));

                average.CopyTo(accelerated_sound, i / 2);
            }

            SoundEffect sound = new SoundEffect(accelerated_sound, microphone.SampleRate, AudioChannels.Mono);
            sound.Play();

            this.durationTalkPiglet = (int)SoundEffect.GetSampleDuration(accelerated_sound.Length, microphone.SampleRate, AudioChannels.Mono).TotalMilliseconds;

            this.timerPigletTalk.Interval = new TimeSpan(0, 0, 0, 0, 100);            
            this.timerPigletTalk.Start();

            this.timerPigletListening.Interval = SoundEffect.GetSampleDuration(accelerated_sound.Length, microphone.SampleRate, AudioChannels.Mono).Add(TimeSpan.FromMilliseconds(1000));
            this.timerPigletListening.Start();

            this.ImagePigletTalk.Source = new BitmapImage(new Uri("/Images/fonem/fonem_" + Convert.ToString(this.rnd.Next(1, 6)) + ".png", UriKind.Relative));
        }

        private void timerPigletListening_Tick(object sender, EventArgs e)
        {
            this.vadState = STATE_LISTENING;
            this.timerPigletTalk.Stop();
            this.timerAnimationPigletDefault.Start();
            this.isPigletTalk = false;
            this.timerPigletListening.Stop();
        }

        private void timerPigletTalk_Tick(object sender, EventArgs e)
        {
            if (this.durationTalkPiglet > 0)
            {
                this.durationTalkPiglet -= 100;
                this.ImagePigletTalk.Source = new BitmapImage(new Uri("/Images/fonem/fonem_" + Convert.ToString(this.rnd.Next(1, 6)) + ".png", UriKind.Relative));
            }
            else {
                this.timerPigletTalk.Stop();
                this.ImagePigletIdle.Visibility = Visibility.Visible;
                this.ImagePigletTalk.Visibility = Visibility.Collapsed;
            }
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
                if (!this.isPigletTalkAvailable)
                {
                    this.isPigletTalkAvailable = true;
                }
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
            this.ImagePigletTalk.Visibility = Visibility.Collapsed;
            this.timerAnimationPigletStart.Stop();
        }

        private void timerAnimationPigletStop_Tick(object sender, EventArgs e)
        {
            this.ImagePigletIdle.Visibility = Visibility.Visible;
            this.MediaPigletVideo.Stop();
            this.timerAnimationPigletStop.Stop();
            this.timerAnimationPigletDefault.Interval = new TimeSpan(0, 0, 0, 1, 0);
            this.timerAnimationPigletDefault.Start();
            this._sensor.Start();           
        }

        private void timerTrialTalk_Tick(object sender, EventArgs e)
        {
            if ((Application.Current as App).TrialMode)
            {
                MessageBoxResult result = MessageBox.Show(AppResources.MessageBoxMessageTalkTrialVersionQuestion, AppResources.MessageBoxHeaderInfo, MessageBoxButton.OKCancel);

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

                this.isPigletTalkDisabledByTrial = true;
            }

            this.timerTrialTalk.Stop();

            this.timerAnimationPigletDefault.Start();
        }

        private void PigletCandy_MouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            if (!this.isPigletTalk && ((Application.Current as App).HasMusicControl || (Application.Current as App).MusicControlTakeover))
            {
                this.isPigletTalkAvailable = false;
                this.ImagePigletIdle.Visibility = Visibility.Visible;
                this.MediaPigletVideo.Stop();
                this.typeAnimation = MODE_ANIMATION_GAME;
                this.MediaPigletVideo.Source = new Uri("/Video/piglet_eats_candy.mp4", UriKind.Relative);
                this.MediaPigletVideo.Play();
            }
        }

        private void ImagePigletCake_MouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            if (!this.isPigletTalk && ((Application.Current as App).HasMusicControl || (Application.Current as App).MusicControlTakeover))
            {
                this.isPigletTalkAvailable = false;
                this.ImagePigletIdle.Visibility = Visibility.Visible;
                this.MediaPigletVideo.Stop();
                this.typeAnimation = MODE_ANIMATION_GAME;
                this.MediaPigletVideo.Source = new Uri("/Video/piglet_eats_cake.mp4", UriKind.Relative);
                this.MediaPigletVideo.Play();
            }
        }

        private void PlayVideoFalls()
        {
            if (!this.isPigletTalk && ((Application.Current as App).HasMusicControl || (Application.Current as App).MusicControlTakeover))
            {
                this.isPigletTalkAvailable = false;
                this.ImagePigletIdle.Visibility = Visibility.Visible;
                this.MediaPigletVideo.Stop();
                this.typeAnimation = MODE_ANIMATION_GAME;
                this.MediaPigletVideo.Source = new Uri("/Video/piglet_falls.mp4", UriKind.Relative);
                this.MediaPigletVideo.Play();
            }
        }

        private void PlayVideoLaughs()
        {
            if (!this.isPigletTalk && ((Application.Current as App).HasMusicControl || (Application.Current as App).MusicControlTakeover))
            {
                this.isPigletTalkAvailable = false;
                this.ImagePigletIdle.Visibility = Visibility.Visible;
                this.MediaPigletVideo.Stop();
                this.typeAnimation = MODE_ANIMATION_GAME;
                this.MediaPigletVideo.Source = new Uri("/Video/piglet_laughs.mp4", UriKind.Relative);
                this.MediaPigletVideo.Play();
            }
        }

        private void PlayVideoInSorrow()
        {
            if ((Application.Current as App).HasMusicControl || (Application.Current as App).MusicControlTakeover)
            {
                this.ImagePigletIdle.Visibility = Visibility.Visible;
                this.MediaPigletVideo.Stop();
                this.typeAnimation = MODE_ANIMATION_DEFAULT;
                this.MediaPigletVideo.Source = new Uri("/Video/piglet_in_sorrow.mp4", UriKind.Relative);
                this.MediaPigletVideo.Play();
            }
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
                    this.isPigletTalkAvailable = false;
                    this.ImagePigletTalk.Visibility = Visibility.Collapsed;
                }
                timeSpan = timeSpan.Subtract(new TimeSpan(0, 0, 0, 0, delta));
                this.timerAnimationPigletStop.Interval = timeSpan;
                this.timerAnimationPigletStop.Start();
            }
        }

        private void ImagePigletFeed_MouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            if (!this.isPigletTalk)
            {
                NavigationService.Navigate(new Uri("/FeedSelectionComplexityPage.xaml", UriKind.Relative));
            }
        }

        private void ImagePigletWash_MouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            if (!this.isPigletTalk)
            {
                if ((Application.Current as App).TrialMode)
                {
                    MessageBoxResult result = MessageBox.Show(AppResources.MessageBoxMessageGameTrialVersionQuestion, AppResources.MessageBoxHeaderInfo, MessageBoxButton.OKCancel);

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
        }

        private void ImagePigletPuzzle_MouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            if (!this.isPigletTalk)
            {
                if ((Application.Current as App).TrialMode)
                {
                    MessageBoxResult result = MessageBox.Show(AppResources.MessageBoxMessageGameTrialVersionQuestion, AppResources.MessageBoxHeaderInfo, MessageBoxButton.OKCancel);

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
        }

        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
            base.OnNavigatedTo(e);

            this.pageNavigationComplete = true;
            this.startAnimationsOnLayoutUpdate = true;
            this.isPigletTalk = false;

            IsolatedStorageSettings.ApplicationSettings.TryGetValue<string>("AnimationPigletPlay", out this.animationPigletPlay);

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

            if (!(Application.Current as App).TrialMode)
            {
                this.isPigletTalkDisabledByTrial = false;
            }
        }

        private void MainPage_LayoutUpdated(object sender, EventArgs e)
        {
            if (this.startAnimationsOnLayoutUpdate && this.pageNavigationComplete)
            {
                ThreadPool.QueueUserWorkItem((stateInfo) =>
                {
                    Deployment.Current.Dispatcher.BeginInvoke(delegate()
                    {
                        if (!(Application.Current as App).HasMusicControl && !(Application.Current as App).MusicControlTakeover)
                        {
                            MessageBoxResult result = MessageBox.Show(AppResources.MessageBoxMessageMusicPauseQuestion, AppResources.MessageBoxHeaderWarning, MessageBoxButton.OKCancel);

                            if (result == MessageBoxResult.OK)
                            {
                                (Application.Current as App).MusicControlTakeover = true;
                            }
                            else
                            {
                                (Application.Current as App).MusicControlTakeover = false;
                            }
                        }
                        if ((Application.Current as App).HasMusicControl || (Application.Current as App).MusicControlTakeover)
                        {                            
                            if (this.animationPigletPlay != null && this.animationPigletPlay != "")
                            {
                                this.isPigletTalkAvailable = false;

                                this.timerAnimationPigletDefault.Stop();

                                if ("WashPigletAnimation" == this.animationPigletPlay)
                                {
                                    this.MediaPigletVideo.Source = new Uri("/Video/piglet_wash_game_finished.mp4", UriKind.Relative);
                                }
                                if ("FeedPigletAnimation" == this.animationPigletPlay)
                                {
                                    this.MediaPigletVideo.Source = new Uri("/Video/piglet_feed_game_finished.mp4", UriKind.Relative);
                                }
                                this.ImagePigletTalk.Visibility = Visibility.Collapsed;
                                this.ImagePigletIdle.Visibility = Visibility.Visible;
                                this.MediaPigletVideo.Stop();
                                this.typeAnimation = MODE_ANIMATION_GAME;
                                this.MediaPigletVideo.Play();
                            }
                            else
                            {
                                if (this.typeAnimation == MODE_ANIMATION_DEFAULT)
                                {
                                    this.isPigletTalkAvailable = true;
                                }
                                else {
                                    this.isPigletTalkAvailable = false;
                                }

                                this.timerAnimationPigletDefault.Start();
                            }

                            this.timerAnimationPigletInSorrow.Start();
                        }
                        else
                        {
                            this.isPigletTalkAvailable = false;
                        }
                    });
                });

                this.startAnimationsOnLayoutUpdate = false;
            }
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
            base.OnNavigatingFrom(e);
            this.isPigletTalkAvailable = false;
            this.pageNavigationComplete = false;

            this.timerAnimationPigletStart.Stop();
            this.timerAnimationPigletStop.Stop();
            this.timerAnimationPigletDefault.Stop();
            this.timerAnimationPigletInSorrow.Stop();

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
                            this.PlayVideoInSorrow();
                        }
                        else
                        {
                            this.PlayVideoLaughs();
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