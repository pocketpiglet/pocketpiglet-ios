using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using Microsoft.Phone.Controls;
using System.Windows.Media.Imaging;
using System.Windows.Threading;
using System.Windows.Navigation;
using System.IO.IsolatedStorage;
using Microsoft.Xna.Framework.Audio;

namespace PocketPiglet
{
    public partial class WashPage : PhoneApplicationPage
    {
        private Image bubbleImage;
        private bool loadOnLayoutUpdate;
        private DispatcherTimer timerRandomNewBubble;
        private Random rnd;
        private int countBursted;
        private int timestampStart;
        private int timestampCurrent;
        private int blunderBubble;
        private bool isGameFinished;
        private string maxScoreWashGame;
        private string animationPigletPlay;
        private string lastGamePiglet;
        public WashPage()
        {
            InitializeComponent();
            this.rnd = new Random();
            this.loadOnLayoutUpdate = false;
            this.countBursted = 0;
            this.timestampStart = (int)ConvertToUnixTimestamp(DateTime.UtcNow);
            this.isGameFinished = false;
            IsolatedStorageSettings.ApplicationSettings.TryGetValue<string>("AnimationPigletPlay", out this.animationPigletPlay);
            IsolatedStorageSettings.ApplicationSettings.TryGetValue<string>("LastGamePiglet", out this.lastGamePiglet);
            IsolatedStorageSettings.ApplicationSettings["LastGamePiglet"] = "wash";
            IsolatedStorageSettings.ApplicationSettings["WashGameState"] = true;
            IsolatedStorageSettings.ApplicationSettings.Save();
        }

        static double ConvertToUnixTimestamp(DateTime date)
        {
            DateTime origin = new DateTime(1970, 1, 1, 0, 0, 0, 0);
            TimeSpan diff = date - origin;
            return Math.Floor(diff.TotalSeconds);
        }

        private void timerRandomNewBubble_Tick(object sender, EventArgs e)
        {
            this.timestampCurrent = (int)ConvertToUnixTimestamp(DateTime.UtcNow);
            int periodGame = this.timestampCurrent - this.timestampStart;
            int countBubble;
            if (periodGame < 10)
            {
                countBubble = 1;
            }
            else if (periodGame < 30)
            {
                countBubble = 2;
            }
            else if (periodGame < 60)
            {
                countBubble = 3;
            }
            else if (periodGame < 90)
            {
                countBubble = 4;
            }
            else
            {
                countBubble = 5;
            }

            for (int i = 1; i <= countBubble; i++)
            {
                this.bubbleImage = new Image();
                this.bubbleImage.Source = new BitmapImage(new Uri("/Images/piglet_wash/bubble_" + Convert.ToString(this.rnd.Next(1, 3)) + ".png", UriKind.Relative));
                this.bubbleImage.Width = 100;
                this.bubbleImage.Height = 100;
                int x = 0;
                int y = 0;
                int width = 100;
                int height = 100;
                int posX = this.rnd.Next(10, 350);
                int posY = this.rnd.Next(450, 600);
                this.bubbleImage.RenderTransform = new TranslateTransform() { X = posX, Y = posY };
                this.bubbleImage.Margin = new Thickness(0, 0, this.GameGrid.ActualWidth - x - width, this.GameGrid.ActualHeight - y - height);
                Canvas.SetZIndex(this.bubbleImage, 3);
                this.bubbleImage.Tag = Convert.ToString("1");
                this.GameGrid.Children.Add(this.bubbleImage);
                Storyboard sb = new Storyboard();
                DoubleAnimation fadeInAnimation = new DoubleAnimation();
                fadeInAnimation.From = (this.bubbleImage.RenderTransform as TranslateTransform).Y;
                fadeInAnimation.To = -100;
                fadeInAnimation.Duration = new Duration(TimeSpan.FromSeconds(3));
                Storyboard.SetTarget(fadeInAnimation, this.bubbleImage);
                Storyboard.SetTargetProperty(fadeInAnimation, new PropertyPath("(UIElement.RenderTransform).(TranslateTransform.Y)"));
                this.bubbleImage.MouseLeftButtonDown += new MouseButtonEventHandler(bubbleImage_MouseLeftButtonDown);
                sb.Completed += new EventHandler(story_Completed);
                sb.Children.Add(fadeInAnimation);
                sb.Begin();
            }
        }

        private void bubbleImage_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            SoundEffectInstance instance = SoundEffect.FromStream(Application.GetResourceStream(new Uri("Sound/piglet_wash/bubble_burst.wav", UriKind.Relative)).Stream).CreateInstance();
            instance.Play();

            this.countBursted++;
            this.textBlockScore.Text = String.Format("{0:D5}", this.countBursted);
            Image item = sender as Image;
            if ((item.Tag as string) == "kill") return;
            item.Source = new BitmapImage(new Uri("/Images/piglet_wash/bubble_bursted.png", UriKind.Relative));
            item.CaptureMouse();
            Storyboard sb = new Storyboard();
            DoubleAnimation fadeInAnimation1 = new DoubleAnimation();
            fadeInAnimation1.From = 1;
            fadeInAnimation1.To = 0.0;
            fadeInAnimation1.Duration = new Duration(TimeSpan.FromSeconds(0.2));
            Storyboard.SetTarget(fadeInAnimation1, item);
            Storyboard.SetTargetProperty(fadeInAnimation1, new PropertyPath("(UIElement.Opacity)"));
            sb.Children.Add(fadeInAnimation1);

            DoubleAnimation fadeInAnimation = new DoubleAnimation();
            fadeInAnimation.From = (item.RenderTransform as TranslateTransform).Y;
            fadeInAnimation.To = (item.RenderTransform as TranslateTransform).Y;
            fadeInAnimation.Duration = new Duration(TimeSpan.FromSeconds(0.1));
            Storyboard.SetTarget(fadeInAnimation, item);
            Storyboard.SetTargetProperty(fadeInAnimation, new PropertyPath("(UIElement.RenderTransform).(TranslateTransform.Y)"));
            sb.Children.Add(fadeInAnimation);
            sb.Completed += new EventHandler(story_BubbleBurstedCompleted);
            item.Tag = "kill";
            sb.Begin();
        }
        private void story_BubbleBurstedCompleted(object sender, EventArgs e)
        {
            var images = this.GameGrid.Children.OfType<Image>();
            List<Image> ImagesListBubble = new List<Image>();
            foreach (var img in images)
            {
                if (img.Opacity == 0)
                {
                    ImagesListBubble.Add(img);
                }
            }
            foreach (var img_delete in ImagesListBubble)
            {
                this.GameGrid.Children.Remove(img_delete);
            }
        }
        private void story_Completed(object sender, EventArgs e)
        {
            var images = this.GameGrid.Children.OfType<Image>();
            List<Image> ImagesListBubble = new List<Image>();
            foreach (var img in images)
            {
                if ((img.RenderTransform as TranslateTransform) != null &&
                    (img.RenderTransform as TranslateTransform).Y < 0)
                {
                    ImagesListBubble.Add(img);
                    this.blunderBubble++;
                }
            }
            foreach (var img_delete in ImagesListBubble)
            {
                this.GameGrid.Children.Remove(img_delete);
            }
            if (this.blunderBubble == 1)
            {
                this.imageMissedBubble4.Source = new BitmapImage(new Uri("/Images/piglet_wash/missed_bubble_grayed.png", UriKind.Relative));
                this.ImageBackgroundWash.Source = new BitmapImage(new Uri("/Images/piglet_wash/background_1_missed.png", UriKind.Relative));
            }
            else if (this.blunderBubble == 2)
            {
                this.imageMissedBubble4.Source = new BitmapImage(new Uri("/Images/piglet_wash/missed_bubble_grayed.png", UriKind.Relative));
                this.imageMissedBubble3.Source = new BitmapImage(new Uri("/Images/piglet_wash/missed_bubble_grayed.png", UriKind.Relative));
                this.ImageBackgroundWash.Source = new BitmapImage(new Uri("/Images/piglet_wash/background_2_missed.png", UriKind.Relative));
            }
            else if (this.blunderBubble == 3)
            {
                this.imageMissedBubble4.Source = new BitmapImage(new Uri("/Images/piglet_wash/missed_bubble_grayed.png", UriKind.Relative));
                this.imageMissedBubble3.Source = new BitmapImage(new Uri("/Images/piglet_wash/missed_bubble_grayed.png", UriKind.Relative));
                this.imageMissedBubble2.Source = new BitmapImage(new Uri("/Images/piglet_wash/missed_bubble_grayed.png", UriKind.Relative));
                this.imageMissedBubble1.Source = new BitmapImage(new Uri("/Images/piglet_wash/missed_bubble_red.png", UriKind.Relative));
                this.ImageBackgroundWash.Source = new BitmapImage(new Uri("/Images/piglet_wash/background_3_missed.png", UriKind.Relative));
            }
            else if (this.blunderBubble >= 4)
            {
                if (!this.isGameFinished)
                {
                    this.imageMissedBubble1.Source = new BitmapImage(new Uri("/Images/piglet_wash/missed_bubble_grayed.png", UriKind.Relative));
                    this.imageMissedBubble2.Source = new BitmapImage(new Uri("/Images/piglet_wash/missed_bubble_grayed.png", UriKind.Relative));
                    this.imageMissedBubble3.Source = new BitmapImage(new Uri("/Images/piglet_wash/missed_bubble_grayed.png", UriKind.Relative));
                    this.imageMissedBubble4.Source = new BitmapImage(new Uri("/Images/piglet_wash/missed_bubble_grayed.png", UriKind.Relative));
                    if (Convert.ToInt32(this.maxScoreWashGame) < this.countBursted)
                    {
                        IsolatedStorageSettings.ApplicationSettings["MaxScoreWashGame"] = Convert.ToString(this.countBursted);
                        this.maxScoreWashGame = Convert.ToString(this.countBursted);
                        IsolatedStorageSettings.ApplicationSettings.Save();
                        this.WashPage_ShowMaxScore();

                        SoundEffectInstance instance = SoundEffect.FromStream(Application.GetResourceStream(new Uri("Sound/piglet_wash/high_score.wav", UriKind.Relative)).Stream).CreateInstance();
                        instance.Play();

                        MessageBoxResult result = MessageBox.Show(AppResources.MessageBoxMessageNewHighscoreQuestion, AppResources.MessageBoxHeaderInfo, MessageBoxButton.OKCancel);
                        if (result == MessageBoxResult.OK)
                        {
                            this.WashPage_StopGame();
                            this.WashPage_StartGame();
                        }
                        else
                        {
                            this.WashPage_StopGame();
                            NavigationService.GoBack();
                        }

                    }
                    else
                    {
                        SoundEffectInstance instance = SoundEffect.FromStream(Application.GetResourceStream(new Uri("Sound/piglet_wash/game_over.wav", UriKind.Relative)).Stream).CreateInstance();
                        instance.Play();

                        MessageBoxResult result = MessageBox.Show(AppResources.MessageBoxMessageGameOverQuestion, AppResources.MessageBoxHeaderInfo, MessageBoxButton.OKCancel);
                        if (result == MessageBoxResult.OK)
                        {
                            this.WashPage_StopGame();
                            this.WashPage_StartGame();
                        }
                        else
                        {
                            this.WashPage_StopGame();
                            NavigationService.GoBack();
                        }
                    }
                }
            }
        }

        private void WashPage_StartGame()
        {
            this.timerRandomNewBubble.Start();

            SoundEffectInstance instance = SoundEffect.FromStream(Application.GetResourceStream(new Uri("Sound/piglet_wash/game_start.wav", UriKind.Relative)).Stream).CreateInstance();
            instance.Play();
        }

        private void WashPage_StopGame()
        {
            var images = this.GameGrid.Children.OfType<Image>();
            List<Image> ImagesListBubble = new List<Image>();
            foreach (var img in images)
            {
                if ((img.RenderTransform as TranslateTransform) != null)
                {
                    ImagesListBubble.Add(img);
                    this.blunderBubble++;
                }
            }
            foreach (var img_delete in ImagesListBubble)
            {
                this.GameGrid.Children.Remove(img_delete);
            }
            this.isGameFinished = true;
            this.timerRandomNewBubble.Stop();
            this.timestampStart = (int)ConvertToUnixTimestamp(DateTime.UtcNow);
            this.isGameFinished = false;
            this.countBursted = 0;
            this.blunderBubble = 0;
            this.textBlockScore.Text = "00000";
            this.imageMissedBubble1.Source = new BitmapImage(new Uri("/Images/piglet_wash/missed_bubble.png", UriKind.Relative));
            this.imageMissedBubble2.Source = new BitmapImage(new Uri("/Images/piglet_wash/missed_bubble.png", UriKind.Relative));
            this.imageMissedBubble3.Source = new BitmapImage(new Uri("/Images/piglet_wash/missed_bubble.png", UriKind.Relative));
            this.imageMissedBubble4.Source = new BitmapImage(new Uri("/Images/piglet_wash/missed_bubble.png", UriKind.Relative));
            this.ImageBackgroundWash.Source = new BitmapImage(new Uri("/Images/piglet_wash/background_0_missed.png", UriKind.Relative));
        }

        private void WashPage_ShowMaxScore()
        {
            int maxScore = Convert.ToInt32(this.maxScoreWashGame);
            this.textBlockScoreMax.Text = String.Format("{0:D5}", maxScore);
        }

        private void WashPage_LayoutUpdated(object sender, EventArgs e)
        {
            if (!this.loadOnLayoutUpdate)
            {
                this.loadOnLayoutUpdate = true;
                this.timerRandomNewBubble = new System.Windows.Threading.DispatcherTimer();
                this.timerRandomNewBubble.Tick += new EventHandler(timerRandomNewBubble_Tick);
                this.timerRandomNewBubble.Interval = new TimeSpan(0, 0, 0, 1, 0);
                this.WashPage_StartGame();
            }
        }

        protected override void OnNavigatingFrom(NavigatingCancelEventArgs e)
        {
            base.OnNavigatingFrom(e);

            this.timerRandomNewBubble.Stop();
            this.isGameFinished = true;
            this.WashPage_StopGame();
            IsolatedStorageSettings.ApplicationSettings["AnimationPigletPlay"] = "WashPigletAnimation";
            IsolatedStorageSettings.ApplicationSettings.Save();
        }

        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
            base.OnNavigatedTo(e);

            IsolatedStorageSettings.ApplicationSettings.TryGetValue<string>("MaxScoreWashGame", out this.maxScoreWashGame);

            if (this.maxScoreWashGame == "" || this.maxScoreWashGame == null)
            {
                this.maxScoreWashGame = "00000";

                IsolatedStorageSettings.ApplicationSettings.Add("MaxScoreWashGame", this.maxScoreWashGame);
                IsolatedStorageSettings.ApplicationSettings.Save();
            }
            this.WashPage_ShowMaxScore();
        }
    }
}